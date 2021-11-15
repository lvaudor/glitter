#' Assemble query parts into a proper SPARQL query
#' @param query a list with elements of the query
#' @param endpoint SPARQL endpoint to send the query to
#' @export
#' @examples
#' spq_add(subject="?city",verb="wdt:P31",object="wd:Q515") %>%
#' spq_add(subject="?city",verb="wdt:P1082",object="?pop", label="?city", language="en") %>%
#' spq_head() %>%
#' build_sparql() %>%
#' cat()
build_sparql=function(query,endpoint="Wikidata"){
  if(endpoint!="Wikidata"){query$service=""}

  query=query %>%
    spq_prefix(auto=TRUE, prefixes=NULL)

  # are prefixes correct and do they correspond to provided prefixes?
  purrr::map_lgl(query$prefixed,
                 glitter:::is_prefix_known,
                 prefixes=usual_prefixes,
                 endpoint=endpoint)
  # prefixes
  if(nrow(query$prefixes)>0){
    part_prefixes=glue::glue("PREFIX {query$prefixes$name}: <{query$prefixes$url}>") %>%
      paste0(collapse="\n")
  }else{part_prefixes=""}

  if(!is.null(query$group_by)){
    query$group_by=paste0("GROUP BY ", paste0(query$group_by, collapse=" "),"\n")
  }
  query=paste0(part_prefixes,"\n",
               "SELECT ", paste0(query$select,collapse=" "),"\n",
               "WHERE{\n",
               query$body,"\n",
               query$filter,"\n",
               query$service,"\n",
               "}\n",
               query$group_by,
               query$order_by,"\n",
               query$limit)
  return(query)
}
