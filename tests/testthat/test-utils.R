test_that("get_cloud_address generates correct URLs", {
  expect_equal(
    get_cloud_address("newpath"),
    "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/newpath"
  )

  expect_equal(
    get_cloud_address("newpath/newfile.sav"),
    "https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/newpath/newfile.sav"
  )

  expect_equal(
    get_cloud_address(fetch_type = "url"),
    "https://cloudstor.aarnet.edu.au/plus/public.php/webdav/"
  )

  expect_equal(
    get_cloud_address("testpath", fetch_type = "url"),
    "https://cloudstor.aarnet.edu.au/plus/public.php/webdav/"
  )
})

test_that("path_or_url correctly detects urls and paths", {
  expect_equal(
    path_or_url("https://cloudstor.aarnet.edu.au/plus/s/ovy2JwDN5GVezHL"),
    "url"
  )
  expect_equal(
    path_or_url("cloudstoR Tests/mydata1.csv"),
    "path"
  )
})

test_that("file_or_folder works", {
  file_metadata <- data.frame(
    file_name = "test.csv",
    tag = "abcdefghijklmnopqrstuvwxyz12345678"
  )

  folder_metadata <- data.frame(
    file_name = c("", "test.csv", "", "test2.csv"),
    tag = c(
      "abcdefghijklmno", "abcdefghijklmnopqrstuvwxyz12345678",
      "abcdefghijklmno", "abcdefghijklmnopqrstuvwxyz12345678"
    )
  )

  expect_equal(file_or_folder(file_metadata), "file")
  expect_equal(file_or_folder(folder_metadata), "folder")
})

test_that("make_dest_path works", {
  testpath <- make_dest_path(NULL, "test.csv")

  expect_true(dir.exists(dirname(testpath)))
  expect_equal(basename(testpath), "test.csv")

  dest <- "test.csv"
  expect_equal(make_dest_path(dest, NULL), "test.csv")
  expect_equal(make_dest_path(dest, "dont_use_this.csv"), "test.csv")
})
