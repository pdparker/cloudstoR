
#' cloud_put
#'
#' @description
#' Save a file to Cloudstor. If the file already exists, it is
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
