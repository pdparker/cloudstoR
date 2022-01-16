# Create a package environment
cloudstoR.env <- new.env(parent = emptyenv()) # nolint

.onLoad <- function(libname, pkgname) { # nolint
  # Set default cloud_address
  op <- options()
  op.cloudstoR <- list( # nolint
    cloudstoR.cloud_address =
      "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/"
  )
  toset <- !(names(op.cloudstoR) %in% names(op))
  if (any(toset)) options(op.cloudstoR[toset])

  assign("authenticated",
         Sys.time() - 5 * 60, # Starts requiring trigger
         cloudstoR.env)

  invisible()
}

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
#' @param user Cloudstor username
#' @param password Cloudstor password
#' @param reset remove the existing authentication and handle
#'
#' @return curl handle object
#' @keywords internal
get_handle <- function(user, password, reset = FALSE) {
  # If authentication has expired, or reset called
  if (
    (difftime(Sys.time(), get("authenticated", envir = cloudstoR.env),
              units = "min") > 5)
    | reset) {
    h <- curl::new_handle(failonerror = TRUE)
    curl::handle_setopt(h, username = user)
    curl::handle_setopt(h, password = password)

    # Save the handle
    assign("handle", h, cloudstoR.env)
    assign("authenticated", Sys.time(), cloudstoR.env)
  } else {
    h <- get("handle", envir = cloudstoR.env)
    # Ensure password is reset to NULL
    curl::handle_setopt(h, password = NULL)
    # Remove custom request if present
    curl::handle_setopt(h, customrequest = NULL)
  }
  return(h)
}

#' cloud_list
#'
#' @description
#' `cloud_list()` returns a list of the files located in a folder.
#'
#' @param path The path to file or folder.
#' @param user Cloudstor user name.
#' @param password Cloudstor password.
#'
#' @return A list of files and folders.
#' @export
cloud_list <- function(path = "",
                       user = cloud_auth_user(),
                       password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(path)
  # fetch directory listing via curl and parse XML response
  h <- get_handle(user, password)
  curl::handle_setopt(h, customrequest = "PROPFIND")
  response <- curl::curl_fetch_memory(cloud_address, h)
  text <- rawToChar(response$content)
  doc <- XML::xmlParse(text, asText = TRUE)
  # calculate relative paths
  base <- paste(paste("/", strsplit(utils::URLdecode(cloud_address),
                                    "/")[[1]][-1:-3],
    sep = "",
    collapse = ""
  ), "/", sep = "")
  result <- unlist(
    XML::xpathApply(doc, "//d:response/d:href", function(node) {
      sub(base, "", utils::URLdecode(XML::xmlValue(node)), fixed = TRUE)
    })
  )
  result[result != ""]
}

#' cloud_get
#'
#' @description
#' `cloud_list()` downloads a file from a Cloudstor folder. The file is opened
#' and read into R using rio, or optionally the file path is returned.
#'
#' @param path The path to file or folder.
#' @param user Cloudstor user name
#' @param password Cloudstor password
#' @param dest The destination for saving the file.
#' @param open_file If TRUE, open the file using rio.
#' Else, returns the file path
#' @param \dots pass additional arguments to `rio::import()`
#'
#' @return The file object or folder path is returned, depending on `open_file`
#' @export
cloud_get <- function(path,
                      dest = NULL,
                      user = cloud_auth_user(),
                      password = cloud_auth_pwd(),
                      open_file = TRUE,
                      ...) {
  cloud_address <- get_cloud_address(path)
  if (is.null(dest)) {
    p <- file.path(tempdir(), basename(path))
  } else {
    p <- file.path(dest)
  }
  h <- get_handle(user, password)
  curl::curl_download(cloud_address, p, handle = h)
  if (open_file) {
    d <- rio::import(p, ...)
    on.exit(unlink(p))
    return(d)
  } else {
    return(p)
  }
}


#' cloud_put
#'
#' @description
#' `cloud_put()` saves a file to Cloudstor. If the file already exists, it is
#' replaced.
#'
#' @param local_file Where the file is located on your computer.
#' @param path The destination on Cloudstor.
#' @param file_name Optional. What you want to call the file on Cloudstor?
#' If it is not provided, it is the same as the file name of the local file
#' @param user Optional. Your Cloudstor username.
#' @param password Optional. Your Cloudstor password.
#'
#' @return Nothing is returned. A success or error message is printed.
#' @export
cloud_put <- function(local_file,
                      path = "",
                      file_name = basename(local_file),
                      user = cloud_auth_user(),
                      password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(file.path(path, file_name))
  in_path <- path.expand(local_file)
  resp <- httr::PUT(cloud_address,
    body = httr::upload_file(in_path),
    config = httr::authenticate(user, password)
  )

  # Alert user on error
  httr::stop_for_status(resp, "upload file")

  if (httr::http_status(resp)$category == "Success") {
    msgtype <- switch(as.character(httr::status_code(resp)),
      "204" = "updated",
      "201" = "added"
    )

    cli::cli_alert_success(sprintf(
      "Success! Your file has been %s.",
      msgtype
    ))
  }

}


#' cloud_meta
#'
#' @description
#' `cloud_meta()` returns the metadata for a file or folder. This can be useful
#' for checking if a file has been modified.
#'
#' @param path The path to file or folder.
#' @param user Your Cloudstor username
#' @param password Your Cloudstor password
#'
#' @return A data.frame of the file and folder metadata is returned.
#' @export
cloud_meta <- function(path = "",
                       user = cloud_auth_user(),
                       password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(path)
  # fetch directory listing via curl and parse XML response
  h <- get_handle(user, password)
  curl::handle_setopt(h, customrequest = "PROPFIND")
  response <- curl::curl_fetch_memory(cloud_address, h)
  text <- rawToChar(response$content)
  doc <- XML::xmlParse(text, asText = TRUE)
  # calculate relative paths
  base <- paste(paste("/", strsplit(cloud_address, "/")[[1]][-1:-3],
    sep = "",
    collapse = ""
  ), "/", sep = "")
  files <- unlist(
    XML::xpathApply(doc, "//d:response/d:href", function(node) {
      sub(base, "", utils::URLdecode(XML::xmlValue(node)), fixed = TRUE)
    })
  )
  modified <- unlist(
    XML::xpathApply(doc, "//d:getlastmodified", function(node) {
      sub(base, "", utils::URLdecode(XML::xmlValue(node)), fixed = TRUE)
    })
  )
  size <- unlist(XML::xpathApply(doc, "//d:response", function(node) {
    contentlength <- unlist(XML::xmlValue(
      node[["propstat"]][["prop"]][["getcontentlength"]]
    ))
    quotaused <- unlist(XML::xmlValue(
      node[["propstat"]][["prop"]][["quota-used-bytes"]]
    ))
    # If no content length, use quota used
    vals <- ifelse(is.na(contentlength), quotaused, contentlength)
    vals
  }))
  tag <- unlist(
    XML::xpathApply(doc, "//d:getetag", function(node) {
      sub(base, "", utils::URLdecode(XML::xmlValue(node)), fixed = TRUE)
    })
  )

  result <- data.frame(
    file_name = files, tag = tag,
    file_modified = modified,
    file_size = size
  )
  return(result)
}


#' cloud_browse
#'
#' @description
#' `cloud_browse()` lets you navigate the folder tree interactively. This is
#' useful for finding a file or folder path which can then be used in
#' `cloud_get()` or `cloud_put()`. This function is only intended to be used
#' interactively - you should not use this function programmatically.
#'
#' When you call `cloud_browse()` you are given a list of files and folders
#' (either at the top-level, or from the provided `path`). You provide the
#' numeric number of the folder or file you wish to move to to continue. If you
#' are not at the top level, you can select "../" to move up one folder. At any
#' time you can select 0 to exit the interactive navigation.
#'
#' If you select a folder, you are shown the files and folders within that
#' folder. If you select a file, the full path for the file is shown (so that
#' it can be passed to another function) and the interactive session is ended.
#'
#' @param path The initial path to start the search. If not provided, the
#' function starts at the top-level folder.
#' @param user Your Cloudstor username.
#' @param password Your Cloudstor password.
#'
#' @return the last file path
#' @export
cloud_browse <- function(path = "",
                         user = cloud_auth_user(),
                         password = cloud_auth_pwd()) {
  choice <- 1
  first_run <- TRUE
  new_path <- path

  while (choice != 0) {
    opts <- cloud_list(path = new_path,
                       user = user,
                       password = password)

    if (new_path != "") {
      # Append only if not at the top of the tree
      opts <- append(opts, "../")
    }

    if (first_run) {
      # Instructions are only shown for the first run
      cli::cli_h1("Cloud Browser")
      cli::cli_text(cli::style_bold("Instructions"))
      cli::cli_text(
        "Select the next location or file.
                    Select \"../\" to move up a level, if possible.
                    Use 0 to exit."
      )
    }

    choice <- utils::menu(opts)
    if (choice != 0) {
      opt_chosen <- opts[[choice]]
      if (opt_chosen == "../") {
        # If move up tree is chosen
        temp_path <- dirname(new_path)
        if (temp_path == ".") {
          new_path <- ""
        } else {
          new_path <- temp_path
        }
      } else {
        # Append the option to the existing path
        if (nchar(new_path) > 0 &
            substr(new_path, nchar(new_path), nchar(new_path)) != "/") {
          new_path <- paste(new_path, opt_chosen, sep = "/")
        } else {
          new_path <- paste(new_path, opt_chosen, sep = "")
        }
      }
    }

    # If the selection is a file, force exit
    if (nchar(new_path) > 0 &
        substr(new_path, nchar(new_path), nchar(new_path)) != "/") {
      choice <- 0
    }
    first_run <- FALSE
  }
  return(new_path)
}
