#' Wikidata properties
#' @format A data frame with 8939 rows and 5 variables:
#' \describe{
#'   \item{id}{id}
#'   \item{type}{property type}
#'   \item{label}{property label}
#'   \item{description}{property description}
#'   \item{altLabel}{alternative labels}
#'   ...
#' }
#' @source Wikidata \url{`r wikidata_url()`}
"wd_properties"

wikidata_url <- function() {
  "https://query.wikidata.org/#SELECT%20%3Fproperty%20%3FpropertyType%20%3FpropertyLabel%20%3FpropertyDescription%20%3FpropertyAltLabel%0AWHERE%20%7B%0A%20%20%3Fproperty%20wikibase%3ApropertyType%20%3FpropertyType.%0A%20%20SERVICE%20wikibase%3Alabel%20%7Bbd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%22.%20%7D%0A%7D%0AORDER%20BY%20ASC%20%28xsd%3Ainteger%28STRAFTER%28STR%28%3Fproperty%29%2C%20%27P%27%29%29%29"
}

#' Usual endpoints: this dataset allows the user to refer to them using a simplified name rather than their full url.
#' @format A data frame with usual SPARQL endpoints and abbreviated names
#' \describe{
#'   \item{name}{the abbreviated name of the SPARQL endpoint}
#'   \item{url}{the full address of the SPARQL endpoint}
#'   ...
#' }
"usual_endpoints"

#' Usual prefixes: this dataset allows the user to refer to usual prefixes in their queries without manually specifying the associated urls.
#' @format A data frame with usual prefixes
#' \describe{
#'   \item{type}{the type of prefix}
#'   \item{name}{the prefix itself}
#'   \item{url}{the corresponding ontology}
#'   ...
#' }
"usual_prefixes"

#' Correspondance between R-DSL functions and SPARQL set functions.
#' @format A data frame.
#' \describe{
#'   \item{R}{R-DSL function}
#'   \item{SPARQL}{SPARQL set function}
#'   \item{args}{list-column with R vs SPARQL argument names}
#' }
"set_functions"

#' Correspondance between R-DSL functions and SPARQL term functions.
#' @format A data frame.
#' \describe{
#'   \item{R}{R-DSL function}
#'   \item{SPARQL}{SPARQL set function}
#' }
"term_functions"
