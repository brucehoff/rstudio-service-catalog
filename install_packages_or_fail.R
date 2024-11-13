#!/usr/bin/env Rscript
# from https://stackoverflow.com/questions/26244530/how-do-i-make-install-packages-return-an-error-if-an-r-package-cannot-be-install
# install the latest versions of a list of packages and fail
# if any package fails to install

packages = commandArgs(trailingOnly=TRUE)

for (l in packages) {

    install.packages(l, dependencies=TRUE, repos=c('http://ran.synapse.org', 'https://cran.rstudio.com'))

    if ( ! library(l, character.only=TRUE, logical.return=TRUE) ) {
        quit(status=1, save='no')
    }
}
