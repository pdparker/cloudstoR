test_that("cloud_get can retrieve a file for a private path", {
  skip_if_no_envs()
  skip_if_offline()

  test_df <- create_testenv()

  expect_equal(
    cloud_get("cloudstoR Tests/mydata1.csv",
      user = Sys.getenv("CLOUD_USER"),
      password = Sys.getenv("CLOUD_PASS")
    ),
    test_df
  )
})

test_that("cloud_get can pass arguments to rio", {
  skip_if_no_envs()
  skip_if_offline()
  test_df <- create_testenv()
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

test_that("cloud_get can fetch a file from a URL", {
  skip_if_no_envs()
  skip_if_offline()

  test_url <- "https://cloudstor.aarnet.edu.au/plus/s/QOrTW9GRjNCivaU"
  test_dest_folder <- create_testenv(store = TRUE, createfile = FALSE)
  test_dest <- tempfile(tmpdir = test_dest_folder, fileext = ".csv")
  test_df <- create_testenv()

  expect_warning(
    cloud_get(test_url),
    "Cannot detect file type & cannot open file. File path returned instead."
  )

  expect_true(file.exists(suppressWarnings(cloud_get(test_url))))

  expect_equal(cloud_get(test_url, test_dest), test_df)
})

test_that("cloud_get can fetch a file from a URL with a password", {
  skip_if_no_envs()
  skip_if_offline()

  test_url <- "https://cloudstor.aarnet.edu.au/plus/s/ceovWSLD5LbyVfP"
  test_pwd <- "Testpassword1!"
  test_dest_folder <- create_testenv(store = TRUE, createfile = FALSE)
  test_dest <- tempfile(tmpdir = test_dest_folder, fileext = ".csv")
  test_df <- create_testenv()

  expect_warning(
    cloud_get(test_url, password = test_pwd),
    "Cannot detect file type & cannot open file. File path returned instead."
  )
  expect_true(
    file.exists(cloud_get(test_url, password = test_pwd, open_file = FALSE))
  )

  expect_equal(cloud_get(test_url, test_dest, password = test_pwd), test_df)
})

test_that("cloud_get can fetch from a URL to a folder", {
  skip_if_no_envs()
  skip_if_offline()

  # Check an empty folder
  empty_folder_url <- "https://cloudstor.aarnet.edu.au/plus/s/OctV40fqrD9E98J"

  expect_warning(
    cloud_get(empty_folder_url),
    "is an empty folder. Nothing returned."
  )

  expect_equal(suppressWarnings(cloud_get(empty_folder_url)), NULL)


  # Check on non-empty folder
  test_url <- "https://cloudstor.aarnet.edu.au/plus/s/EOlUzLt1bez8998"
  test_dest_folder <- create_testenv(store = TRUE, createfile = FALSE)

  expect_warning(
    cloud_get(test_url, test_dest_folder),
    "Argument `open_file` ignored: cannot open a folder."
  )
  expect_equal(
    list.files(test_dest_folder), c("mydata1.csv", "mydata2.csv", "mydata3.csv")
  )
})

test_that("cloud_get can fetch from a URL to a folder", {
  skip_if_no_envs()
  skip_if_offline()

  test_url <- "https://cloudstor.aarnet.edu.au/plus/s/zaQ4oA3zGmowaSz"
  test_pwd <- "Testpassword1!"
  test_dest_folder <- create_testenv(store = TRUE, createfile = FALSE)

  expect_warning(
    cloud_get(test_url, test_dest_folder, password = test_pwd),
    "Argument `open_file` ignored: cannot open a folder."
  )
  expect_equal(
    list.files(test_dest_folder), c("mydata1.csv", "mydata2.csv", "mydata3.csv")
  )
})
