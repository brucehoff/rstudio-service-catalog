#!/usr/bin/env Rscript
# install a specific version of a given package and fail if
# the package fails to install

theargs = commandArgs(trailingOnly=TRUE)

package=theargs[1]
version=theargs[2]

install.packages('remotes', dependencies=TRUE, repos='https://cran.rstudio.com')
remotes::install_version(package, version = version, repos = 'https://cran.rstudio.com')

if ( ! library(package, character.only=TRUE, logical.return=TRUE) ) {
        quit(status=1, save='no')
}
