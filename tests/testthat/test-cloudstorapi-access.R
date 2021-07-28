library(cloudstoR)
library(mockery)

mock_resp <- "<?xml version=\"1.0\"?>\n<d:multistatus xmlns:d=\"DAV:\" xmlns:s=\"http://sabredav.org/ns\" xmlns:oc=\"http://owncloud.org/ns\"><d:response><d:href>/plus/remote.php/webdav/</d:href><d:propstat><d:prop><d:getlastmodified>Wed, 09 Jun 2021 05:08:23 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>472824158981</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;9e8348556d5b1230dd96e6f152e26b5b&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response><d:response><d:href>/plus/remote.php/webdav/BelongingProject/</d:href><d:propstat><d:prop><d:getlastmodified>Wed, 09 Jun 2021 05:12:45 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>1359721519</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;60c04dd04a0b8&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response><d:response><d:href>/plus/remote.php/webdav/Documents/</d:href><d:propstat><d:prop><d:getlastmodified>Fri, 31 May 2019 06:23:52 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>36227</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;5cf0c88be4ef9&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response><d:response><d:href>/plus/remote.php/webdav/Photos/</d:href><d:propstat><d:prop><d:getlastmodified>Fri, 31 May 2019 06:23:52 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>678556</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;5cf0c88be4ef9&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response><d:response><d:href>/plus/remote.php/webdav/Shared/</d:href><d:propstat><d:prop><d:getlastmodified>Mon, 11 Jan 2021 04:56:56 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>470681303339</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;097d627213d3e5684b571f34d70a1509&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response><d:response><d:href>/plus/remote.php/webdav/iPLAY%20Data/</d:href><d:propstat><d:prop><d:getlastmodified>Wed, 10 Mar 2021 11:26:23 GMT</d:getlastmodified><d:resourcetype><d:collection/></d:resourcetype><d:quota-used-bytes>782419339</d:quota-used-bytes><d:quota-available-bytes>1097368772135</d:quota-available-bytes><d:getetag>&quot;60493b3ebf967&quot;</d:getetag></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat><d:propstat><d:prop><d:getcontentlength/><d:getcontenttype/></d:prop><d:status>HTTP/1.1 404 Not Found</d:status></d:propstat></d:response></d:multistatus>"

# get_cloud_address

test_that("Generate URLs", {
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

test_that("Returns correct list", {
  exp_res <- c(
    "BelongingProject/", "Documents/", "Photos/",
    "Shared/", "iPLAY Data/"
  )

  # Skip credentials
  stub(cloud_list, "cloud_auth_user", NULL)
  stub(cloud_list, "cloud_auth_pwd", NULL)

  # Don't submit request
  stub(cloud_list, "curl::curl_fetch_memory", NULL)

  # Use dummy returned text
  stub(cloud_list, "rawToChar", mock_resp)

  expect_equal(cloud_list(), exp_res)
})
