#' get_cloud_address
#'
#' Return the full cloud_address path. Not a user facing function.
#'
#' @param path path to file or folder
#'
#' @return encoded url as string
#' @keywords internal
get_cloud_address <- function(path) {
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
