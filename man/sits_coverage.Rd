% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_coverage.R
\name{sits_coverage}
\alias{sits_coverage}
\title{Provides information about one coverage used to retrieve data}
\usage{
sits_coverage(service = "RASTER", name, timeline = NULL, bands = NULL,
  missing_values = NULL, scale_factors = NULL, minimum_values = NULL,
  files = NA)
}
\arguments{
\item{service}{name of the time series service}

\item{name}{name of the coverage}

\item{timeline}{vector - timeline of the coverage}

\item{bands}{vector - bands}

\item{missing_values}{vector - missing values for each band}

\item{scale_factors}{vector - scale factor for each band}

\item{minimum_values}{vector - minimum values for each band}

\item{files}{vector - file names for each band (only for raster data)}
}
\description{
uses the configuration file to print information and save metadata about a
chosen coverage:
 service        - name of time series service that provides the coverage (e.g., "WTSS", "SATVEG", "RASTER")
 name           - name of the coverage (must be unique)
 bands          - vector of bands
 scale_factor   - vector of scale factors
 missing_values - vector of missing values
 minimum_values - vector of minimum values
 timeline       - the timelines of the coverage (more than one if data has been classified)
 xmin           - spatial extent (xmin)
 ymin           - spatial extent (ymin)
 xmax           - spatial extent (xmax)
 ymax           - spatial extent (ymin)
 xres           - spatial resolution (x dimension)
 yres           - spatial resolution (y dimension)
 crs            - Projection crs
 files          - Files associated with the coverage (in case of raster data)
}
\examples{
\donttest{
# Example 1. Retrieve information about a WTSS coverage
coverage.tb <- sits_coverage(service = "WTSS-INPE", name = "MOD13Q1")

# Example 2. Create a raster coverage with metadata
# read a raster file and put it into a vector
files  <- c(system.file ("extdata/raster/mod13q1/sinop-crop-ndvi.tif", package = "sits"))

# create a raster coverage file based on the information about the files
raster.tb <- sits_coverage(service = "RASTER", name  = "Sinop-crop",
             timeline = timeline_modis_392, bands = c("ndvi"), files = files)
}
}
