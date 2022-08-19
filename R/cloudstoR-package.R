#' @keywords internal
"_PACKAGE"

# Create a package environment
cloudstoR.env <- new.env(parent = emptyenv()) # nolint

.onLoad <- function(libname, pkgname) { # nolint
  # Set default cloud_address
  op <- options()
  op.cloudstoR <- list( # nolint
    cloudstoR.cloud_address =
      "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/",
    cloudstoR.cloud_address_public =
      "https://cloudstor.aarnet.edu.au/plus/public.php/webdav/"
  )
  toset <- !(names(op.cloudstoR) %in% names(op))
  if (any(toset)) options(op.cloudstoR[toset])

  assign(
    "authenticated",
    Sys.time() - 5 * 60, # Starts requiring trigger
    cloudstoR.env
  )

  invisible()
}

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
