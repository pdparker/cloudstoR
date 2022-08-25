# cloud_list
test_that("cloud_list returns a correct list of files and folders", {
  skip_if_no_envs()
  skip_if_offline()
  exp_res <- c(
    "Another Folder/", "Empty Folder/", "mydata1.csv", "mydata2.csv",
    "mydata3.csv"
  )

  expect_equal(
    cloud_list("cloudstoR Tests",
      user = Sys.getenv("CLOUD_USER"),
      password = Sys.getenv("CLOUD_PASS")
    ),
    exp_res
  )
})
