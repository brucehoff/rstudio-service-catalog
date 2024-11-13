#!/usr/bin/env Rscript
# from https://stackoverflow.com/questions/26244530/how-do-i-make-install-packages-return-an-error-if-an-r-package-cannot-be-install
# this script signals failure if a package fails to install

theargs = commandArgs(trailingOnly=TRUE)

package=theargs[1]
version=theargs[2]

install.packages('remotes', dependencies=TRUE, repos='https://cran.rstudio.com')
remotes::install_version(package, version = version, repos = 'https://cran.rstudio.com')

if ( ! library(package, character.only=TRUE, logical.return=TRUE) ) {
        quit(status=1, save='no')
}
