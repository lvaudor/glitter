#' Assemble query parts into a sparql query and send it to endpoint to get a tibble as a result.
#' @param .query a list with elements of the query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @export
#' @examples
#' query=spq_init() %>%
#' spq_add(subject="?city",verb="wdt:P31",object="wd:Q515") %>%
#' spq_add(subject="?city",verb="wdt:P1082",object="?pop", label="?city") %>%
#' spq_head(n=5) %>%
#'
#' spq_perform()
spq_perform = function(.query, endpoint = "Wikidata"){
  sparql_query = spq_assemble(.query = .query, endpoint = endpoint)

  send_sparql(sparql_query, endpoint = endpoint)

}
