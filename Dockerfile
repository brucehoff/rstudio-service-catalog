FROM ubuntu:22.04

# What follows is the Docker implementation of the Packer definition of an RStudio image:
# https://github.com/Sage-Bionetworks-IT/packer-rstudio/blob/master/src/playbook.yaml
# omitting the addition of the reverse proxy

# Update the repository sources list and install RStudio dependencies
# list from https://github.com/rstudio/rstudio/blob/main/dependencies/linux/install-dependencies-jammy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
apt-get install -y --no-install-recommends \
aptdaemon \
ant \
build-essential \
clang \
curl \
debsigs \
dpkg-sig \
expect \
fakeroot \
gdebi-core \
git \
gnupg1 \
jq \
libacl1-dev \
libattr1-dev \
libbz2-dev \
libcap-dev \
libclang-dev \
libcurl4-openssl-dev \
libegl1-mesa \
libfuse2 \
libgl1-mesa-dev \
libgtk-3-0 \
libpam-dev \
libpango1.0-dev \
libpq-dev \
libsqlite3-dev \
libssl-dev \
libuser1-dev \
libxslt1-dev \
lsof \
openjdk-8-jdk \
openjdk-11-jdk \
ninja-build \
p7zip-full \
patchelf \
pkg-config \
rrdtool \
software-properties-common \
unzip \
uuid-dev \
wget \
zlib1g-dev \
apache2 \
apache2-dev \
flex \
ssl-cert \
libxml2-dev \
libpq5 \
libffi-dev \
libcurl4-openssl-dev \
libapparmor1 \
libxml2-dev \
libharfbuzz-dev \
libfribidi-dev \
libfreetype6-dev \
libpng-dev \
libtiff5-dev \
libjpeg-dev \
software-properties-common \
python3 \
python3-venv \
python3-boto3 \
python-is-python3 \
psmisc \
sudo \
&& apt-get clean

# Install R (see https://docs.posit.co/resources/install-r/)
# Install R 4.3.2
ENV R_VERSION=4.3.2
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2204/pkgs/r-${R_VERSION}_1_amd64.deb
RUN gdebi -n r-${R_VERSION}_1_amd64.deb
RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
RUN ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# from https://community.rstudio.com/t/running-rstudio-server-as-non-root/161714/2
ARG USERNAME=rstudio
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
RUN echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME
RUN echo "$USERNAME:$USERNAME" | sudo chpasswd

USER rstudio
# Create directory for user R packages
ENV R_PACKAGE_LIBRARY=/home/rstudio/R/x86_64-pc-linux-gnu-library/4.3/
RUN mkdir -p ${R_PACKAGE_LIBRARY}

USER root
# Create directory for the following step
RUN mkdir -p /etc/systemd/system.conf.d

# Update file access limits for all processes
COPY 60-DefaultLimitNOFILE.conf /etc/systemd/system.conf.d/60-DefaultLimitNOFILE.conf

# Download RStudio Server
ENV RSTUDIO_FILE_NAME=rstudio-server-2023.12.0-369-amd64.deb
WORKDIR /tmp
RUN curl -O https://s3.amazonaws.com/rstudio-ide-build/server/jammy/amd64/${RSTUDIO_FILE_NAME}

# Install RStudio Server
RUN dpkg -i /tmp/${RSTUDIO_FILE_NAME}

# Overwrite rstudio web config
COPY rserver.conf /etc/rstudio/rserver.conf
COPY startup.sh /startup.sh

# Install essential R packages

USER rstudio
# Install tidyverse, devtools, BiocManager
RUN R -e "install.packages(c('tidyverse','devtools','BiocManager'), repos=c('https://packagemanager.posit.co/cran/__linux__/jammy/latest'), lib=c('${R_PACKAGE_LIBRARY}'))"

# Install synapser
# environment variable needed to communicate with the embedded python and install boto3 dependency
RUN R -e "Sys.setenv(SYNAPSE_PYTHON_CLIENT_EXTRAS='boto3'); install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'), Ncpus = 2, lib=c('${R_PACKAGE_LIBRARY}'))"

USER root
CMD /startup.sh
