# Ensure required libraries are installed
# Install missing dependencies for devtools

required_packages <- c("CBASSED50", "shiny", "bslib", "dplyr", "tidyr", "ggplot2", "readxl", "rstudioapi", "RColorBrewer", "shinycssloaders", "shinyjs", "devtools", "bslib")

for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg, dependencies = TRUE, repos='https://cloud.r-project.org')
        library(pkg, character.only = TRUE)
    }
}

devtools::install_local("/tmp/shinycbass_0.0.1.tar.gz", force = TRUE)

library("CBASSED50")
library("shinycbassed50")