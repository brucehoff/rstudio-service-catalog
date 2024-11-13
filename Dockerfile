FROM rocker/rstudio:4.4.1

# no login required
ENV DISABLE_AUTH=true

RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y install libpng-dev \
libcurl4-openssl-dev \
libxml2-dev \
libfontconfig1-dev \
python3 \
python3-pip \
python3-venv \
python3-boto3 \
python-is-python3 && \
apt-get clean

USER rstudio

# This is needed to make reticulate work
# https://github.com/rstudio/reticulate/issues/1509
RUN python3 -m pip install virtualenv

# Install R packages
ADD install_packages_or_fail.R /
RUN Rscript --no-save install_packages_or_fail.R tidyverse devtools BiocManager reticulate
# Install synapser and, by extension, the synapse Python client
RUN Rscript --no-save install_packages_or_fail.R synapser
# Install Python package boto3, which will be used by the synapse Python client
RUN R -e "reticulate::virtualenv_install(reticulate::virtualenv_list()[1], 'boto3')"

# Let rstudio have sudo access without having to enter a password
USER root
RUN echo 'rstudio   ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
