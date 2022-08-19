#' cloud_meta
#'
#' @description
#' Return the metadata for a file or folder. This can be useful
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
