#' Assemble query parts into a sparql query and send it to endpoint to get a tibble as a result.
#' @param query_parts a list with elements of the query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @export
#' @examples
#' add_triplets(subject="?city",verb="wdt:P31",object="wd:Q515", limit=10) %>%
#' add_triplets(subject="?city",verb="wdt:P1082",object="?pop", label="?city", language="en") %>%
#' send()
send=function(query_parts, endpoint="Wikidata"){
  sparql_query=build_sparql(query_parts=query_parts,endpoint=endpoint)
  result=send_sparql(sparql_query, endpoint=endpoint)
  return(result)
}
