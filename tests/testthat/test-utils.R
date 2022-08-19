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
