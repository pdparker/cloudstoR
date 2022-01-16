
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cloudstoR

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/cloudstoR)](https://CRAN.R-project.org/package=cloudstoR)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/pdparker/cloudstoR/workflows/R-CMD-check/badge.svg)](https://github.com/pdparker/cloudstoR/actions)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/last-month/cloudstoR?color=blue)](https://r-pkg.org/pkg/cloudstoR)
<!-- badges: end -->

The goal of `cloudstoR` is to simplify accessing data stored on
[Cloudstor](https://cloudstor.aarnet.edu.au/) via their WebDAV
interface. You can use `cloudstoR` to download or upload files, or check
the contents of directories.

## Installation

You can install from
[CRAN](https://cran.r-project.org/package=cloudstoR) with:

``` r
install.packages("cloudstoR")
```

Or install the development version from
[GitHub](https://github.com/pdparker/cloudstoR) with:

``` r
# install.packages("devtools")
devtools::install_github("pdparker/cloudstoR")
```

For additional support for the package, check the [pkgdown
site](https://pdparker.github.io/cloudstoR/).

## Setup

You will need your Cloudstor username and password. The password is
**not** the one you use to log on to Cloudstor. Instead you need to use
an [app
password](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-).
`cloudstoR` provides an option to store these credentials using
[`keyring`](https://github.com/r-lib/keyring).

## Examples

### Setting credentials

The first time you use a `cloud_*` function, `cloudstoR` will prompt you
to store your credentials locally. You can choose not to do this by
providing a username and password for each function call.

``` r
library(cloudstoR)
my_data <- cloud_get(path = 'cloudstoR Tests/mydata1.csv',
                     username = cloudstor_username,
                     password = cloudstor_appPassword)
```

### Getting a list of files

To retrieve a list of files in a folder, use `cloud_list()`. The `path`
argument specifies the folder to return.

``` r
cloud_list(path = 'cloudstoR Tests')
#> [1] "Another Folder/" "mydata1.csv"     "mydata2.csv"
```

### Getting a specific file

To retrieve a file use `cloud_get()`, and provide the path to the file
with the `path` argument.

``` r
my_data <- cloud_get(path = 'cloudstoR Tests/mydata1.csv')
my_data
#>   A  B  C
#> 1 3 10  8
#> 2 5  7  5
#> 3 5  7 10
```

By default, `cloudstoR` will try to open the file using
[`rio`](https://github.com/leeper/rio) and return a data.frame. The
temporary version of the file is deleted once it is read into memory. If
you want to use a different package to open the file, or you just want
to download and keep the file without opening it, set
`open_file = FALSE` to return a file path instead.

``` r
my_path <- cloud_get(path = 'cloudstoR Tests/mydata1.csv',
                     dest = "~/mydata1.csv",
                     open_file = FALSE)
file.exists(my_path)
#> [1] TRUE
```

### Saving a file to Cloudstor

To upload a file, use `cloud_put()`. You need to provide the path to the
saved file (`local_file`), and the path to save the file on Cloudstor
(`path`). You can optionally provide a name for the file (`file_name`),
otherwise the file name of the local file is used.

``` r
cloud_put(local_file = '~/datatosave.sav',
          path = 'additional/path/to/folder',
          file_name = 'mydata.sav',)
```

### Navigating the folder tree

If you don’t know the exact file path you want to follow, you can find
it with `cloud_browse()`.

![Example of `cloud_browse`](man/figures/cloud_browse_demo.gif)

### View file or folder meta-data

You can view meta-data for a file or folder with `cloud_meta()`. This
can be especially useful for checking if a file has been modified.

``` r
cloud_meta(path = 'cloudstoR Tests/mydata1.csv')
#>                                             file_name
#> 1 /plus/remote.php/webdav/cloudstoR Tests/mydata1.csv
#>                                  tag                 file_modified file_size
#> 1 "9a2a8fdd58a6c2746cd65b7dace6115c" Sun, 16 Jan 2022 05:42:52 GMT        36
```

### Updating credentials

If you need to delete your credentials (e.g., because you revoke your
app password), you can restore them by calling `cloud_auth()` directly:

``` r
cloud_auth(reset_keys=TRUE)
```

### Using an alternative WebDAV address

The default WebDAV address is
`https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/`. If your
organisation uses a different address, you can set this globally at the
top of your script:

``` r
# Set the global WebDAV address
options(cloudstoR.cloud_address = "https:://my.webdav.address")
# Check the current value
getOption("cloudstoR.cloud_address")
```
