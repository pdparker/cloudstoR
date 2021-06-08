
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
We recommend you save both your username and password in your
.Renvironment or .Rprofile.

## Example

    library(cloudstoR)
    ## basic example code
    my_data = cloud_get(user = cloudstor_user,
                        password = cloudstor_password,
                        dest = 'mydata.sav',
                        cloud_address = 'https://cloudstor.aarnet.edu.au/plus/remote.php/webdav/mydata.sav')
