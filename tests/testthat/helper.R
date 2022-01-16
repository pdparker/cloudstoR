skip_if_no_envs <- function() {
  testthat::skip_if(
    nchar(Sys.getenv("CLOUD_USER", unset = "")) == 0,
    "Environment variable not available"
  )
  testthat::skip_if(
    nchar(Sys.getenv("CLOUD_PASS", unset = "")) == 0,
    "Environment variable not available"
  )
}
