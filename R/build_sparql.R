#' Assemble query parts into a query.
#' @param query_parts a list with elements of the query
#' @endpoint
#' @export
#' @examples
#' add_triplets(subject="?city",verb="wdt:P31",object="wd:Q515", limit=10) %>%
#' add_triplets(subject="?city",verb="wdt:P1082",object="?pop", label="?city", language="en") %>%
#' build_sparql() %>%
#' cat()
build_sparql=function(query_parts,endpoint="Wikidata"){
  if(endpoint!="Wikidata"){query_parts$service=""}
  query=paste0(query_parts$prefixes,"\n",
               "SELECT ", paste0(query_parts$select,collapse=" "),"\n",
               "WHERE{\n",
               query_parts$body,"\n",
               query_parts$filter,"\n",
               query_parts$service,"\n",
               "}\n",
               query_parts$limit,
               query_parts$group_by)
  return(query)
}
