# Setup
test_df <- data.frame(A = sample(1:10, 3, replace = TRUE),
                      B = sample(1:10, 3, replace = TRUE),
                      C = sample(1:10, 3, replace = TRUE))

test_folder <- file.path(tempdir(), "cloudstor_tests")
test_file <- file.path(test_folder, "mydata1.csv")
dir.create(test_folder)
write.csv(test_df, test_file, row.names = FALSE)

# get_cloud_address

test_that("get_cloud_address generates correct URLs", {
  expect_equal(
    get_cloud_address("newpath"),
    "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/newpath"
  )

  expect_equal(
    get_cloud_address("newpath/newfile.sav"),
    "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/newpath/newfile.sav"
  )
})

# cloud_list
test_that("cloud_list returns a correct list of files and folders", {
  skip_if_no_envs()
  skip_if_offline()
  exp_res <- c("Another Folder/", "mydata1.csv", "mydata2.csv")

  expect_equal(cloud_list("cloudstoR Tests",
                          user = Sys.getenv("CLOUD_USER"),
                          password = Sys.getenv("CLOUD_PASS")),
               exp_res)
})

# cloud_put
test_that("cloud_put can store a file", {
  skip_if_no_envs()
  skip_if_offline()
  # This fails if an error is returned
  expect_error(suppressMessages(cloud_put(test_file,
                         path = "cloudstoR Tests",
                         user = Sys.getenv("CLOUD_USER"),
                         password = Sys.getenv("CLOUD_PASS"))),
               NA)
})

# cloud_get
test_that("cloud_get can retrieve a file", {
  skip_if_no_envs()
  skip_if_offline()
  expect_equal(cloud_get("cloudstoR Tests/mydata1.csv",
                         user = Sys.getenv("CLOUD_USER"),
                         password = Sys.getenv("CLOUD_PASS")),
               test_df)

})

test_that("cloud_get can pass arguements to rio", {
  skip_if_no_envs()
  skip_if_offline()
  expect_equal(cloud_get("cloudstoR Tests/mydata1.csv",
                         user = Sys.getenv("CLOUD_USER"),
                         password = Sys.getenv("CLOUD_PASS"),
                         # Pass nrows to rio
                         nrows = 1
                         ),
               test_df[1, ])
})

# cloud_meta
test_that("cloud_meta returns correct information", {
  skip_if_no_envs()
  skip_if_offline()
  meta_resp <- cloud_meta("cloudstoR Tests")

  # Returns correct columns
  expect_equal(names(meta_resp),
               c("file_name", "tag", "file_modified", "file_size"))

  # Should be four files/folders
  expect_length(meta_resp, 4)

})

# Clean up
unlink(test_folder, recursive = TRUE)
