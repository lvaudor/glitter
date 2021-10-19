#' Assemble query parts into a query.
#' @param query_parts a list with elements of the query
#' @param endpoint SPARQL endpoint to send the query to
#' @export
#' @examples
#' add_triplets(subject="?city",verb="wdt:P31",object="wd:Q515") %>%
#' add_triplets(subject="?city",verb="wdt:P1082",object="?pop", label="?city", language="en") %>%
#' spq_head() %>%
#' build_sparql() %>%
#' cat()
build_sparql=function(query_parts,endpoint="Wikidata"){
  if(endpoint!="Wikidata"){query_parts$service=""}

  # are uri correct and do they correspond to provided prefixes?
  uri_ok=purrr::map_lgl(query_parts$uris,is_uri_correct,
                        prefixes=query_parts$prefixes,
                        endpoint=endpoint)
  # prefixes
  if(nrow(query_parts$prefixes)>0){
    part_prefixes=glue::glue("PREFIX {query_parts$prefixes$name}: <{query_parts$prefixes$url}>\n")
  }else{part_prefixes=""}

  query=paste0(part_prefixes,
               "SELECT ", paste0(query_parts$select,collapse=" "),"\n",
               "WHERE{\n",
               query_parts$body,"\n",
               query_parts$filter,"\n",
               query_parts$service,"\n",
               "}\n",
               query_parts$group_by,"\n",
               query_parts$order_by,"\n",
               query_parts$limit)
  return(query)
}
