
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cloudstoR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

The goal of `cloudstoR` is to simplify accessing data stored on
[cloudstor](https://cloudstor.aarnet.edu.au/) via their WebDAV
interface. You can use `cloudstoR` to download or upload files, or check
the contents of directories.

## Installation

You can install from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("pdparker/cloudstoR")
```

Or install the development version with:

``` r
# install.packages("devtools")
devtools::install_github("pdparker/cloudstoR", ref = "dev")
```

## Setup

You will need your cloudstor username and password. The password is not
the one you use to log on to cloudstor. Instead you need to use an [app
password](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-).
`cloudstoR` provides an option to store these credentials using
[`keyring`](https://github.com/r-lib/keyring).

## Example

``` r
library(cloudstoR)
## basic example code
my_data = cloud_get(path = 'mydata.sav')
```

Note that calling any of the `cloud_*` functions without a username or
password prompts `cloudstoR` to store your credentials locally. You can
choose not to do this by providing a username and password.

``` r
my_data = cloud_get(path = 'mydata.sav',
                    username = cloudstor_username,
                    password = cloudstor_appPassword)
```

### Getting a list of files

``` r
cloud_list(path = 'additional/path/to/folder')
```

### Getting a specific file

``` r
my_data = cloud_get(path = 'mydata.sav')
```

Note that `cloudstoR` will try to open the file using
[`rio`](https://github.com/leeper/rio) and return a data.frame. If you
want to use a different package to open the file, or you just want to
download the file without opening it, set `open_file = FALSE` to return
a file path instead.

``` r
my_path = cloud_get(path = 'mydata.sav',
                    open_file = FALSE)
```

### Saving a file to Cloudstor

``` r
cloud_put(file_name = 'mydata.sav',
          local_file = '~/datatosave.sav',
          path = 'additional/path/to/folder')
```

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
