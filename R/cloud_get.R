#' Fetch a file or files from Cloudstor
#'
#' Download a file or files from a Cloudstor folder. The file is opened and
#' read into R using rio, or optionally the file path is returned. You can
#' provide either a path to a private Cloudstor file, or a public URL (with
#' optional password) to either a single file or a folder.
#'
#' @param path The path to file or URL to file or folder.
#' @param user Cloudstor username. Not needed for a URL.
#' @param password Cloudstor password or optional password to public link.
#' @param dest The destination for saving the file.
#' @param open_file If TRUE, open the file using rio.
#' Else, returns the file path. This is ignored if the URL is a folder.
#' @param \dots pass additional arguments to `rio::import()`
#'
#' @return The file object or folder path is returned, depending on `open_file`
#' @export
cloud_get <- function(path,
                      dest = NULL,
                      user = NULL,
                      password = NULL,
                      open_file = TRUE,
                      ...) {
  fetch_type <- path_or_url(path)
  cloud_address <- get_cloud_address(path, fetch_type)

  if (fetch_type == "path") {
    if (is.null(user)) user <- cloud_auth_user()
    if (is.null(password)) password <- cloud_auth_pwd()
    return(
      cloud_get_path(cloud_address, path, dest, user, password, open_file, ...)
    )
  }

  if (fetch_type == "url") {
    user <- basename(path)
    if (is.null(password)) password <- ""
    return(
      cloud_get_url(cloud_address, path, dest, user, password, open_file, ...)
    )
  }
}


#' Get file from a path
#'
#' The engine function for [cloud_get()], when the provided path is a private
#' file path. Not intended to be invoked directly.
#'
#' @param cloud_address Address to use for fetching.
#' @param path The path to the file on cloudstor.
#' @param dest The optional path to save the file.
#' @param user Cloudstor username
#' @param password Cloudstor password
#' @param open_file If TRUE, open the file using rio.
#' Else, returns the file path.
#' @param \dots pass additional arguments to `rio::import()`
#'
#' @return The file object or folder path is returned, depending on `open_file`
#' @keywords internal
#' @seealso [cloud_get_url()]
cloud_get_path <- function(cloud_address,
                           path, dest, user, password, open_file, ...) {
  p <- make_dest_path(dest, path)
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


#' Get file(s) from a public URL
#'
#' FUNCTION_DESCRIPTION
#'
#' @param cloud_address Address to use for fetching.
#' @param url The url to the file or folder.
#' @param dest The optional path to save the file(s).
#' @param user The 'key' for the public link. This is the last part of the
#' public URL
#' @param password The password for the public link. If there is no password,
#' use `NULL` or `""`.
#' @param open_file If TRUE, open the file using rio.
#' Else, returns the file path. This is ignored if the URL is to a folder.
#' @param \dots pass additional arguments to `rio::import()`
#'
#' @return One of: file object, file path, or a folder path.
#' @seealso [cloud_get_path()]
cloud_get_url <- function(cloud_address,
                          url, dest, user, password, open_file, ...) {
  # Get the structure
  url_meta <- cloud_meta(url, password = password, fetch_type = "url")
  url_type <- file_or_folder(url_meta)

  if (url_type == "file" & is.null(dest) & open_file) {
    cli::cli_warn(
      "Cannot detect file type & cannot open file. File path returned instead."
    )
    open_file <- FALSE
  }

  # Simplest case: the url is a single file
  if (url_type == "file") {
    return(
      cloud_get_path(cloud_address, NULL, dest, user, password, open_file, ...)
    )
  }

  # Deal with folders
  if (url_type == "folder" & nrow(url_meta) == 1) {
    cli::cli_warn("{url} is an empty folder. Nothing returned.")
    return(NULL)
  }

  if (url_type == "folder" & open_file) {
    cli::cli_warn(
      "Argument `open_file` ignored: cannot open a folder.
      List of file paths returned instead.
      Silence this warning with `open_file = FALSE`"
    )
    open_file <- FALSE
  }

  files_to_fetch <- url_meta$file_name[url_meta$file_name != ""]
  if (is.null(dest)) dest <- tempdir()
  file_locations <- vector(mode = "character", length = length(files_to_fetch))

  cli::cli_progress_bar(
    format = paste0(
      "{cli::pb_spin} Downloading {.path {filename}} ",
      "[{cli::pb_current}/{cli::pb_total}]   ETA:{cli::pb_eta}"
    ),
    format_done = paste0(
      "{cli::col_green(cli::symbol$tick)} Downloaded {cli::pb_total} files ",
      "in {cli::pb_elapsed}."
    ),
    total = length(files_to_fetch)
  )

  for (i in seq_len(length(files_to_fetch))) {
    filename <- files_to_fetch[[i]]
    cli::cli_progress_update()
    file_dest <- file.path(dest, filename)
    file_cloud_address <- utils::URLencode(paste0(cloud_address, filename))
    file_locations[[i]] <- cloud_get_path(
      file_cloud_address, NULL, file_dest, user, password, open_file
    )
  }

  return(file_locations)
}
