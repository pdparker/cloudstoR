
#' cloud_list
#'
#' @description
#' Return a list of the files located in a folder.
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
  base <- paste(paste("/", strsplit(
    utils::URLdecode(cloud_address),
    "/"
  )[[1]][-1:-3],
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
