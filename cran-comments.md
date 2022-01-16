## Test environments

* GitHub Actions (ubuntu-20.04):  release, devel
* GitHub Actions (windows): release
* Github Actions (macOS): release

## R CMD check results

0 errors | 0 warnings | 0 note

Note that this package interacts with a third-party API which requires 
authentication. Therefore, most tests are skipped on CRAN, but are run (and 
are passing) locally and on GitHub actions.

## Comments

This is a minor update to the existing package, mostly to create better 
documentation and add additional tests. These notes might be helpful:

* Note that ‘Cloudstor’ and ‘WebDAV’ are correctly spelled.
* The third-party API is called 'Cloudstor', and this package is 'cloudstoR'.
