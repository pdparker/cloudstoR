# cloudstoR (development version)

To be released as cloudstoR 0.2.0.

* Minor housekeeping (updates to README and DESCRIPTION).
* Users can now pass additional arguments to rio::import via cloud_get. For example, to set the column types or to choose the number or rows to import.
* `cloud_put` no returns a meaningful message on success or failure.
* New tests and workflow to directly test the API.
* `cloud_get` now deletes the temporary file one it is loaded into memory.

# cloudstoR 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* First version released on CRAN.
