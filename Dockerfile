FROM rocker/rstudio:4.3.2

# no login required
ENV DISABLE_AUTH=true

RUN apt-get -y update && \
apt-get -y install libpng-dev \
python3 \
python3-pip \
python3-venv \
python3-boto3 \
python-is-python3 && \
apt-get clean

# Let rstudio have sudo access without having to enter a password
RUN echo 'rstudio   ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

USER rstudio

# This is needed to make reticulate work
# https://github.com/rstudio/reticulate/issues/1509
RUN python3 -m pip install virtualenv


# Install essential R packages

# Install tidyverse, devtools, BiocManager
RUN R -e "install.packages(c('tidyverse','devtools','BiocManager'))"

# Install synapser
# environment variable needed to communicate with the embedded python and install boto3 dependency
RUN R -e "Sys.setenv(SYNAPSE_PYTHON_CLIENT_EXTRAS='boto3'); install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

USER root
