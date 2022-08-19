# cloud_put
test_that("cloud_put can store a file", {
  skip_if_no_envs()
  skip_if_offline()
  test_file <- create_testdf(store = TRUE)

  # This fails if an error is returned
  expect_error(
    suppressMessages(cloud_put(test_file,
      path = "cloudstoR Tests",
      user = Sys.getenv("CLOUD_USER"),
      password = Sys.getenv("CLOUD_PASS")
    )),
    NA
  )
})
