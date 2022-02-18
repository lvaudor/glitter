#' Builds the "filter" part of a query.
#' @param query a list with elements of the query*
#' @param expressions the vector of filtering expressions to apply
#' @export
#' @examples
#' # Corpus of articles with "wikidata" in the title
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q13442814") %>%
#' spq_add("?item rdfs:label ?itemTitle") %>%
#' spq_filter("CONTAINS(LCASE(?itemTitle),'wikidata')") %>%
#' spq_filter("LANG(?itemTitle)='en'") %>%
#' spq_head(n=5)
spq_filter=function(query=NULL, expressions){
  if(!is.null(query)){part_filter=query$filter}else{part_filter=c()}
  part_filter_to_add=paste0("FILTER(",expressions,")\n")%>%
    paste0(collapse="")
  part_filter=paste0(part_filter,part_filter_to_add)
  query$filter=part_filter
  return(query)
}
