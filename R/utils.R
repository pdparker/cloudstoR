#' get_cloud_address
#'
#' Return the full cloud_address path. Not a user facing function.
#'
#' @param path path to file or folder
#'
#' @return encoded url as string
#' @keywords internal
get_cloud_address <- function(path, fetch_type = "path") {
  if (fetch_type == "url") {
    return(utils::URLencode(getOption("cloudstoR.cloud_address_public")))
  }

  cloud_address <- paste0(getOption("cloudstoR.cloud_address"), path)
  cloud_address <- utils::URLencode(cloud_address)
  return(cloud_address)
}

#' get_handle
#'
#' Return a handle for CURL to use. Not a user facing function
#'
#' @param user Cloudstor username or file key (for public links)
#' @param password Cloudstor password or file password (for public links)
#' @param reset remove the existing authentication and handle
#' @param save save the new handle for reuse
#'
#' @return curl handle object
#' @keywords internal
get_handle <- function(user, password, reset = FALSE, save = TRUE) {
  # If authentication has expired, or reset called
  if (
    (difftime(Sys.time(), get("authenticated", envir = cloudstoR.env),
      units = "min"
    ) > 5) |
      reset) {
    h <- curl::new_handle(failonerror = TRUE)
    curl::handle_setopt(h, username = user)
    curl::handle_setopt(h, password = password)
  } else {
    h <- get("handle", envir = cloudstoR.env)
    # Ensure password is reset to NULL
    curl::handle_setopt(h, password = NULL)
    # Remove custom request if present
    curl::handle_setopt(h, customrequest = NULL)
    save <- FALSE
  }

  if (save) {
    assign("handle", h, cloudstoR.env)
    assign("authenticated", Sys.time(), cloudstoR.env)
  }

  return(h)
}

#' Check if using a file path or a URL
#'
#' Checks if the string provided to `path` in the `cloud_*` functions are a
#' Cloudstor path or a URL (indicating a public file or folder).
#' Not a user facing function.
#'
#' @param item The user-provided string.
#'
#' @return "path" or "url"
#' @keywords internal
path_or_url <- function(item) {
  if (startsWith(item, "https://")) {
    return("url")
  }

  return("path")
}


#' Check if metadata indicates a file or folder
#'
#' Used internally to check if a path should be treated as a folder or a single
#' file.
#'
#' @param metadata metadata as returned by [cloud_meta()].
#'
#' @return One of c("folder", "file")
#' @keywords internal
file_or_folder <- function(metadata) {
  if (nrow(metadata) > 1) {
    return("folder")
  }

  if (nchar(metadata$tag) > 15) {
    return("file")
  }

  return("folder")
}


#' Generate the path for saving files
#'
#' Used internally to determine where files should be saved.
#'
#' @param dest The optional destination provided by the user.
#' @param path The path to the file on cloudstor.
#'
#' @return A file path that can be used for saving files.
#' @keywords internal
make_dest_path <- function(dest, path = NULL) {
  if (is.null(dest) & !is.null(path)) {
    return(file.path(tempdir(), basename(path)))
  }

  if (is.null(dest)) {
    return(file.path(tempfile()))
  }

  return(file.path(dest))
}
