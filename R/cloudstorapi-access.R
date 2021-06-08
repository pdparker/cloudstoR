
#' cloud_list
#'
#' @param user cloudstor user name
#' @param password cloudstor password
#' @param cloud_address the cloudstor webdav address to your file/folder of interest
#'
#' @return
#' @export
#'
#' @examples
cloud_list <- function(user, password, cloud_address = "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/") {
  uri <- utils::URLencode(cloud_address)
  # fetch directory listing via curl and parse XML response
  h <- curl::new_handle()
  curl::handle_setopt(h, customrequest = "PROPFIND")
  curl::handle_setopt(h, username = user)
  curl::handle_setopt(h, password = password)
  response <- curl::curl_fetch_memory(uri, h)
  text <- rawToChar(response$content)
  doc <- XML::xmlParse(text, asText=TRUE)
  # calculate relative paths
  base <- paste(paste("/", strsplit(uri, "/")[[1]][-1:-3], sep="", collapse=""), "/", sep="")
  result <- unlist(
    XML::xpathApply(doc, "//d:response/d:href", function(node) {
      sub(base, "", utils::URLdecode(XML::xmlValue(node)), fixed=TRUE)
    })
  )
  result[result != ""]
}

#' cloud_get
#'
#' @param user cloudstor user name
#' @param password cloudstor password
#' @param cloud_address cloudstor webDav address to file of interest
#' @param dest destination for saving the file
#'
#' @return
#' @export
#'
#' @examples
cloud_get <- function(user, password, cloud_address, dest){
  p = file.path(tempdir(), dest)
  h = curl::new_handle()
  curl::handle_setopt(h, username = user)
  curl::handle_setopt(h, password = password)
  curl::curl_download(cloud_address, p, handle = h)
  d = readit::readit(p)
  return(d)
}


#' Title
#'
#' @param file_name What you want to call the file on cloudstor
#' @param local_file Where the file is located
#' @param user Your cloudstor username
#' @param password Your cloudstor password
#' @param cloud_address cloudstor webDav address to the location you want to save on cloudstor
#'
#' @return
#' @export
#'
#' @examples
cloud_put <- function(file_name, local_file, user, password,  cloud_address = "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/") {
  uri <- utils::URLencode(file.path(cloud_address, file_name))
  in_path = path.expand(local_file)
  httr::PUT(uri, body = httr::upload_file(in_path), config = httr::authenticate(user, password))
}
