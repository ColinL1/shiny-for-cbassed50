# Use the rocker/shiny image as the base image
FROM rocker/shiny:latest

# Will copy from existing Docker image
COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda

ENV PATH=/opt/conda/bin:$PATH

# Usage examples
RUN set -ex && \
    conda config --set always_yes yes --set changeps1 no && \
    conda info -a && \
    conda config --add channels conda-forge && \
    conda install --quiet --freeze-installed -c conda-forge r-bslib r-colourpicker r-pbkrtest r-reshape2 r-drc r-RcppEigen r-base r-DT r-shiny r-bslib r-dplyr r-tidyr r-ggplot2 r-readxl r-rstudioapi r-rcolorbrewer r-shinycssloaders r-shinyjs r-devtools r-usethis r-pkgdown r-roxygen2 r-rversions r-urlchecker

# Copy the tar.gz package
COPY shinycbassed50_0.0.1.tar.gz /tmp/shinycbassed50_0.0.1.tar.gz

COPY install_packages.R /tmp/install_packages.R

RUN chown shiny:shiny /tmp/install_packages.R

# Run the package installation script
RUN chmod +x /tmp/install_packages.R

# Modify your RUN command to:
RUN Rscript /tmp/install_packages.R

# Instead, create an app.R that loads your package and runs the app:
COPY app.R /srv/shiny-server/shiny_cbass/

# Copy Shiny server configuration file
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server/shiny_cbass

# Expose Shiny Server port
EXPOSE 3838

# Expose port and start server as before
CMD ["/usr/bin/shiny-server"]
