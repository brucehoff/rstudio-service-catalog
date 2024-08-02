# rstudio-service-catalog

An RStudio Docker image suitable for the Sage Service Catalog Notebook product

In addition to R-Studio, the image has commonly used R packages: `tidyverse`, `devtools`, `BiocManager`, `synapser`.

To run:


```
docker run -d -p 8787:8787 ghcr.io/sage-bionetworks-it/rstudio-service-catalog:1.0.0
```

## Versioning

Semantic versioning is used and containers are tagged based on GitHub tags: If a tag,
1.2.3 is pushed to GitHub then a container image is built with tags `1.2.3` as well as `1.2`.
Thus the `major.minor` tag is overwritten when the repo' is patched.


## Security

Trivy is run on each built container and they will not be published
to `ghcr.io` if any CRITICAL or HIGH
vulnerabilites are found.  Trivy is also run daily to check for new
vulnerabilities in existing images.  So periodic review of new findings
is needed:  Go to the Security tab in GitHub, select Code Scanning at left,
and then select Branch > Main to check for new findings.  To suppress
false positives, either:

- Enter the CVE in `.trivyignore`, or

- Enter the file to skip while scanning in the `trivy.yml` workflow.

In either case, add a comment justifying why the finding is suppressed.
