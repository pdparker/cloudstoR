
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cloudstoR

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/cloudstoR)](https://CRAN.R-project.org/package=cloudstoR)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/pdparker/cloudstoR/workflows/R-CMD-check/badge.svg)](https://github.com/pdparker/cloudstoR/actions)
<!-- badges: end -->

The goal of `cloudstoR` is to simplify accessing data stored on
[cloudstor](https://cloudstor.aarnet.edu.au/) via their WebDAV
interface. You can use `cloudstoR` to download or upload files, or check
the contents of directories.

## Installation

You can install from
[CRAN](https://cran.r-project.org/package=cloudstoR) with:

``` r
install.packages("cloudstoR")
```

Or install the development version from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("pdparker/cloudstoR")
```

## Setup

You will need your cloudstor username and password. The password is
**not** the one you use to log on to cloudstor. Instead you need to use
an [app
password](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-).
`cloudstoR` provides an option to store these credentials using
[`keyring`](https://github.com/r-lib/keyring).

## Example

``` r
library(cloudstoR)
my_data = cloud_get(path = 'cloudstoR Tests/mydata1.csv')
```

Note that calling any of the `cloud_*` functions without a username or
password prompts `cloudstoR` to store your credentials locally. You can
choose not to do this by providing a username and password.

``` r
my_data = cloud_get(path = 'cloudstoR Tests/mydata1.csv',
                    username = cloudstor_username,
                    password = cloudstor_appPassword)
```

### Getting a list of files

``` r
cloud_list(path = 'cloudstoR Tests')
#> [1] "Another Folder/" "mydata1.csv"     "mydata2.csv"
```

### Getting a specific file

``` r
my_data = cloud_get(path = 'cloudstoR Tests/mydata1.csv')
my_data
#>   A B  C
#> 1 6 6  9
#> 2 5 4 10
#> 3 8 7 10
```

Note that `cloudstoR` will try to open the file using
[`rio`](https://github.com/leeper/rio) and return a data.frame. The
temporary version of the file is deleted once it is read into memory. If
you want to use a different package to open the file, or you just want
to download and keep the file without opening it, set
`open_file = FALSE` to return a file path instead.

``` r
my_path = cloud_get(path = 'cloudstoR Tests/mydata1.csv',
                    dest="~/mydata1.csv",
                    open_file = FALSE)
file.exists(my_path)
#> [1] TRUE
```

### Saving a file to Cloudstor

``` r
cloud_put(file_name = 'cloudstoR Tests/mydata.sav',
          local_file = '~/datatosave.sav',
          path = 'additional/path/to/folder')
```

### Navigating the folder tree

If you don’t know the exact file path you want to follow, you can find
it with `cloud_browse()`.

![Example of `cloud_browse`](man/figures/cloud_browse%20demo.gif)

### Updating credentials

If you need to delete your credentials (e.g., because you revoke your
app password), you can restore them by calling `cloud_auth()` directly:

``` r
cloud_auth(reset_keys=TRUE)
```

### Using an alternative webdav address

The default webdav address is
`https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/`. If your
organisation uses a different address, you can set this globally at the
top of your script:

``` r
# Set the global webdav address
options(cloudstoR.cloud_address = "https:://my.webdav.address")
# Check the current value
getOption("`cloudstoR`.cloud_address")
```
