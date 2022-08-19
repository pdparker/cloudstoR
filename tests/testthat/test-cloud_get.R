test_that("cloud_get can retrieve a file", {
  skip_if_no_envs()
  skip_if_offline()

  test_df <- create_testdf()

  expect_equal(
    cloud_get("cloudstoR Tests/mydata1.csv",
      user = Sys.getenv("CLOUD_USER"),
      password = Sys.getenv("CLOUD_PASS")
    ),
    test_df
  )
})

test_that("cloud_get can pass arguements to rio", {
  skip_if_no_envs()
  skip_if_offline()
  test_df <- create_testdf()
  expect_equal(
    cloud_get("cloudstoR Tests/mydata1.csv",
      user = Sys.getenv("CLOUD_USER"),
      password = Sys.getenv("CLOUD_PASS"),
      # Pass nrows to rio
      nrows = 1
    ),
    test_df[1, ]
  )
})
