# rstudio-service-catalog

An RStudio Docker image suitable for the Sage Service Catalog Notebook product

This is based on the Packer-built AMI defined [here](https://github.com/rstudio/rstudio/blob/main/dependencies/linux/install-dependencies-jammy)

In addition to R-Studio, the image has commonly used R packages: `tidyverse`, `devtools`, `BiocManager`, `synapser`.

To run:


```
docker run -d -p 8787:8787 ghcr.io/sage-bionetworks-it/rstudio-service-catalog:v1.0.0
```
