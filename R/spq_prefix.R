#' Add prefixes to the query
#' @param query a list with elements of the query
#' @param prefixes a vector of prefixes
#' @export
#' @examples
#' spq_init() %>%
#' spq_prefix(prefixes=c(dbo="http://dbpedia.org/ontology/"))
spq_prefix=function(query=NULL,auto=TRUE, prefixes=NULL){
  if(!is.null(prefixes)){auto=FALSE}
  if(!is.data.frame(prefixes) & !is.null(prefixes)){
    prefixes=tibble::tibble(name=names(prefixes),
                            url=prefixes,
                            type="user")
  }
  if(auto==TRUE){
    prefixes_auto=usual_prefixes %>%
      filter(name %in% query$prefixes_used) %>%
      filter(type!="Wikidata")
    prefixes=bind_rows(prefixes,prefixes_auto)
  }
  prefixes=prefixes %>%
    select(name,url) %>%
    unique()

  query$prefixes_provided=bind_rows(query$prefixes_provided,
                                    prefixes) %>%
    unique()
  return(query)
}
