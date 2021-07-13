# Create a package environment
cloudstoR.env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Set default cloud_address
  op <- options()
  op.cloudstoR <- list(
    cloudstoR.cloud_address =
      "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/"
  )
  toset <- !(names(op.cloudstoR) %in% names(op))
  if (any(toset)) options(op.cloudstoR[toset])

  assign("authenticated", FALSE, cloudstoR.env)

  invisible()
}

#' get_cloud_address
#'
#' Return the full cloud_address path. Not a user facing function.
#'
#' @param path path to file or folder
#'
#' @return
#'
#' @examples
get_cloud_address <- function(path) {
  cloud_address <- paste0(getOption("cloudstoR.cloud_address"), path)
  return(cloud_address)
}

#' get_handle
#'
#' Return a handle for CURL to use. Not a user facing function
#'
#' @param user cloudstor username
#' @param password cloudstor password
#' @param reset remove the existing authentication and handle
#'
#' @return curl handle object
#'
#' @examples
get_handle <- function(user, password, reset = FALSE) {
  # If not authenticated or reset
  if (!get("authenticated", envir = cloudstoR.env) | reset) {
    h <- curl::new_handle(failonerror = TRUE)
    curl::handle_setopt(h, username = user)
    curl::handle_setopt(h, password = password)

    # Save the handle
    assign("handle", h, cloudstoR.env)
    assign("authenticated", TRUE, cloudstoR.env)
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
#' @param path path to file or folder
#' @param user cloudstor user name
#' @param password cloudstor password
#'
#' @return
#' @export
#'
#' @examples
cloud_list <- function(path = "",
                       user = cloud_auth_user(),
                       password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(path)
  uri <- utils::URLencode(cloud_address)
  # fetch directory listing via curl and parse XML response
  h <- get_handle(user, password)
  curl::handle_setopt(h, customrequest = "PROPFIND")
  response <- curl::curl_fetch_memory(uri, h)
  text <- rawToChar(response$content)
  doc <- XML::xmlParse(text, asText = TRUE)
  # calculate relative paths
  base <- paste(paste("/", strsplit(uri, "/")[[1]][-1:-3],
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
#' Download a file from a cloudstor folder and open it in R.
#'
#' @param path path to file or folder
#' @param user cloudstor user name
#' @param password cloudstor password
#' @param dest destination for saving the file
#'
#' @return
#' @export
#'
#' @examples
cloud_get <- function(path = "",
                      user = cloud_auth_user(),
                      password = cloud_auth_pwd(),
                      dest) {
  cloud_address <- get_cloud_address(path)
  p <- file.path(tempdir(), dest)
  h <- get_handle(user, password)
  curl::curl_download(cloud_address, p, handle = h)
  d <- readit::readit(p)
  return(d)
}


#' cloud_put
#'
#' Save a file to cloudstor.
#'
#' @param file_name What you want to call the file on cloudstor
#' @param local_file Where the file is located
#' @param path path to file or folder
#' @param user Your cloudstor username
#' @param password Your cloudstor password
#'
#' @return
#' @export
#'
#' @examples
cloud_put <- function(file_name,
                      local_file,
                      path = "",
                      user = cloud_auth_user(),
                      password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(path)
  uri <- utils::URLencode(file.path(cloud_address, file_name))
  in_path <- path.expand(local_file)
  httr::PUT(uri,
    body = httr::upload_file(in_path),
    config = httr::authenticate(user, password)
  )
}


#' cloud_meta
#'
#' Return a data.frame of the metadata for a file or folder
#'
#' @param path path to file or folder
#' @param user Your cloudstor username
#' @param password Your cloudstor password
#'
#' @return
#' @export
#'
#' @examples
cloud_meta <- function(path = "",
                       user = cloud_auth_user(),
                       password = cloud_auth_pwd()) {
  cloud_address <- get_cloud_address(path)
  uri <- utils::URLencode(cloud_address)
  # fetch directory listing via curl and parse XML response
  h <- get_handle(user, password)
  curl::handle_setopt(h, customrequest = "PROPFIND")
  response <- curl::curl_fetch_memory(uri, h)
  text <- rawToChar(response$content)
  doc <- XML::xmlParse(text, asText = TRUE)
  # calculate relative paths
  base <- paste(paste("/", strsplit(uri, "/")[[1]][-1:-3],
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
