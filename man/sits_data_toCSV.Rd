% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sits_csv.R
\name{sits_data_toCSV}
\alias{sits_data_toCSV}
\title{Export a SITS tibble data to the CSV format}
\usage{
sits_data_toCSV(data.tb, file)
}
\arguments{
\item{data.tb}{a tibble with time series data and metadata}

\item{file}{name of the exported CSV file}
}
\value{
status     status of the operation
}
\description{
Converts time series data from a SITS tibble to a CSV file. The CSV file will not contain the metadata,
but will have the actual time series, with a reference value. This function is useful to
export the data for external applications
}
\examples{
\donttest{
# read a tibble with 400 samples of Cerrado and 346 samples of Pasture
data(cerrado_2classes)
# export a time series to zoo
sits_data_toCSV (cerrado_2classes, file = "./cerrado_2classes.csv")
}
}
\author{
Gilberto Camara, \email{gilberto.camara@inpe.br}
}
