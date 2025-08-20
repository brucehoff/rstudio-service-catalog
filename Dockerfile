FROM rocker/rstudio:4.5.1

# no login required
ENV DISABLE_AUTH=true

RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y install libpng-dev \
libcurl4-openssl-dev \
libxml2-dev \
libfontconfig1-dev \
libgit2-dev \
libfontconfig1-dev \
libfribidi-dev \
libfreetype6-dev \
libpng-dev \
libtiff5-dev \
libjpeg-dev \
libharfbuzz-dev \
python3 \
python3-pip \
python3-venv \
python3-boto3 \
python-is-python3 && \
apt-get clean

USER rstudio

# This is needed to make reticulate work
# https://github.com/rstudio/reticulate/issues/1509
#RUN python3 -m pip install virtualenv

# Install R packages
ADD install_packages_or_fail.R /
ADD install_versioned_package_or_fail.R /
# synapser depends on rjson 0.2.21, but a newer version is installed by default
RUN Rscript --no-save install_versioned_package_or_fail.R rjson 0.2.21
RUN Rscript --no-save install_packages_or_fail.R tidyverse devtools BiocManager reticulate

# install BioConductor (v. 3.21 is for R version 4.5)
RUN Rscript -e 'BiocManager::install(version = "3.21")'


RUN Rscript -e 'reticulate::virtualenv_create("r-reticulate")'

# Install synapser and, by extension, the synapse Python client
RUN Rscript --no-save install_packages_or_fail.R synapser

# Install Python package boto3, which will be used by the synapse Python client
RUN R -e "reticulate::virtualenv_install(reticulate::virtualenv_list()[1], 'boto3')"

# Let rstudio have sudo access without having to enter a password
USER root
RUN echo 'rstudio   ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
