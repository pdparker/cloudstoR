#' cloud_get
#'
#' @description
#' Download a file from a Cloudstor folder. The file is opened
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
