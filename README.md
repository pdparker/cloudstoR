
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cloudstoR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

The goal of cloudstoR is to …

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("pdparker/cloudstoR")
```

## Setup

You will need your cloudstor username and password. The password is not
the one you use to log on to cloudstor. Instead you need to use an [app
password](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-).
cloudstoR provides an option to store these credentials using
[`keyring`](https://github.com/r-lib/keyring).

## Example

``` r
library(cloudstoR)
## basic example code
my_data = cloud_get(dest = 'mydata.sav',
                    cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/mydata.sav')
```

Note that calling any of the `cloud_*` functions without a username or
password prompts cloudstoR to store your credentials locally. You can
choose not to do this by providing a username and password.

``` r
my_data = cloud_get(username = cloudstor_username,
                    password = cloudstor_appPassword,
                    dest = 'mydata.sav',
                    cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/mydata.sav')
```

### Getting a list of files

``` r
cloud_list(cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/additional/path/to/folder')
```

### Getting a specific file

``` r
my_data = cloud_get(dest = 'mydata.sav',
                    cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/mydata.sav')
```

### Saving a file to Cloudstor

``` r
cloud_put(file_name = 'mydata.sav',
          local_file = '~/datatosave.sav',
          cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/additional/path/to/folder')
```

### Updating credentials

If you need to delete your credentials (e.g., because you revoke your
app password), you can restore them by calling `cloud_auth()` directly:

``` r
cloud_auth(reset_keys=TRUE)
```
