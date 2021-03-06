% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_part_select.R
\name{build_part_select}
\alias{build_part_select}
\title{Builds the "select" part of a query.}
\usage{
build_part_select(
  query = NULL,
  subject = NULL,
  verb = NULL,
  object = NULL,
  label = NA
)
}
\arguments{
\item{query}{a list with elements of the query}

\item{subject}{an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))}

\item{verb}{the property (for instance "wdt:P190")}

\item{object}{an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))}

\item{label}{whether to get the label associated with the mentioned item}
}
\description{
Builds the "select" part of a query.
}
