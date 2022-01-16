# cloudstoR 0.2.0

* Minor housekeeping (updates to `README` and `DESCRIPTION`).
* Users can now pass additional arguments to `rio::import()` via `cloud_get`. For example, to set the column types or to choose the number or rows to import.
* `cloud_put` now returns a meaningful message on success or failure.
* New tests and workflow to directly test the API.
* `cloud_get` now deletes the temporary file once it is loaded into memory.
* Expand on the documentation and create a pkgdown site to provide user support.

# cloudstoR 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* First version released on CRAN.
