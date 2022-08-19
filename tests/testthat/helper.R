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

create_testdf <- function(store = FALSE, env = parent.frame()) {
  test_df <- data.frame(
    A = 1:3,
    B = letters[1:3],
    C = c("1/7/2022", "7/1/2021", "10/10/2020")
  )

  if (store) {
    test_folder <- file.path(tempdir(), "cloudstor_tests")
    test_file <- file.path(test_folder, "mydata1.csv")
    dir.create(test_folder)
    write.csv(test_df, test_file, row.names = FALSE)
    withr::defer(unlink(test_folder, recursive = TRUE),
      envir = env
    )
    return(test_file)
  }

  return(test_df)
}
