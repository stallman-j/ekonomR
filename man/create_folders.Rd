% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/00_create-folders.R
\name{create_folders}
\alias{create_folders}
\title{Create Folders}
\usage{
create_folders(
  home_folder,
  data_folder = NULL,
  output_folder = NULL,
  data_external_folder = NULL,
  data_pii_folder = NULL
)
}
\arguments{
\item{home_folder}{The main project folder where code lives. Not specified to a default so that you have to know where your home folder lives.}

\item{data_folder}{The folder where data lives, defaults to file.path(home_folder,"data")}

\item{output_folder}{The folder where output lives. Defaults to file.path(home_folder,"output")}

\item{data_external_folder}{a folder for an external hard drive with different data. Only gets created if specified; default to NULL creates nothing}

\item{data_pii_folder}{a home folder with data with personal identitifying information (PII) which may need to be separately created. Only gets created if specified, default to NULL creates nothing.}
}
\value{
a bunch of folders
}
\description{
create_folders is a function that creates your project folders in a number of (possibly separate) locations: the home_folder (where your code lives, and which would ideally by synced to a github repository); the data_folder; and the output_folder, which is where output goes. The reason these three are kept separate is for potential space constraints: the home_folder code may not take up much space and should be easy to sync to Github. The data_folder may be space intensive. For small projects which are not set up with GitHub, the data_folder and output_folder may reasonably be subdirectories of home_folder. Additional options are given for separate locations for external data and for data which contains sensitive information (E.g. personally identifying information or PII)
}
\examples{
my_home_folder <- file.path("P:","Projects","ECON-412_js")
create_folders(home_folder = my_home_folder)
}
