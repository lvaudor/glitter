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
#' @source \url{"https://query.wikidata.org/#SELECT%20%3Fproperty%20%3FpropertyType%20%3FpropertyLabel%20%3FpropertyDescription%20%3FpropertyAltLabel%0AWHERE%20%7B%0A%20%20%3Fproperty%20wikibase%3ApropertyType%20%3FpropertyType.%0A%20%20SERVICE%20wikibase%3Alabel%20%7Bbd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cen%22.%20%7D%0A%7D%0AORDER%20BY%20ASC%20%28xsd%3Ainteger%28STRAFTER%28STR%28%3Fproperty%29%2C%20%27P%27%29%29%29"}
"wd_properties"
