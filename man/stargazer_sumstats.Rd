% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/03_analysis.R
\name{stargazer_sumstats}
\alias{stargazer_sumstats}
\title{Stargazer sumstats, good defaults for stargazer}
\usage{
stargazer_sumstats(
  data,
  type = "latex",
  style = "qje",
  summary = TRUE,
  covariate.labels = NULL,
  summary.stat = c("n", "min", "mean", "median", "max", "sd"),
  digits = 2,
  out_path = here::here("output", "01_tables"),
  output_filename = "summary_stats.tex",
  title = "Summary Statistics",
  label = "tab:summary_stats",
  float = FALSE
)
}
\arguments{
\item{data}{dataset you would like summarized. Assumed to be the case that all the columns you want are included}

\item{type}{output type for stargazer}

\item{style}{input to starza}

\item{summary}{TRUE, whether to make the thing sumstats}

\item{covariate.labels}{default NULL in which case you use varnames}

\item{summary.stat}{which sum stats to display}

\item{digits}{number of significant digits, default is 2}

\item{out_path}{output path, default here::here("output","01_tables")}

\item{output_filename}{filename for the output, default "summary_stats.tex"}

\item{title}{Title of the table, default "summary statistics"}

\item{label}{default label for the table}

\item{float}{whether to float in latex, default FALSE so that tabular environment is removed}
}
\value{
output tables in both latex and text format, both to console and in the output_path location, with nice defaults
}
\description{
Stargazer sumstats, good defaults for stargazer
}
