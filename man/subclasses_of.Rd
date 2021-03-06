% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/explore_classes.R
\name{subclasses_of}
\alias{subclasses_of}
\title{Get subclasses of a Wikidata class}
\usage{
subclasses_of(id, include_self = FALSE)
}
\arguments{
\item{id}{the id of class}

\item{include_self}{whether to include class itself in the results table}
}
\description{
Get subclasses of a Wikidata class
}
\examples{
subclasses_of("wd:Q7930989")
}
