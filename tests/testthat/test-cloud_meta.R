# cloud_meta
test_that("cloud_meta returns correct information", {
  skip_if_no_envs()
  skip_if_offline()
  meta_resp <- cloud_meta("cloudstoR Tests",
    user = Sys.getenv("CLOUD_USER"),
    password = Sys.getenv("CLOUD_PASS")
  )

  # Returns correct columns
  expect_equal(
    names(meta_resp),
    c("file_name", "tag", "file_modified", "file_size")
  )

  # Should be four files/folders
  expect_length(meta_resp, 4)
})
