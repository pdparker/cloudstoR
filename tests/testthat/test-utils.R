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
