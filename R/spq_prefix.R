#' Add prefixes to the query
#' @param query a list with elements of the query
#' @param prefixes a vector of prefixes
#' @export
spq_prefix=function(query=NULL,auto=TRUE, prefixes=NULL){
  if(!is.null(prefixes)){auto=FALSE}
  if(!is.data.frame(prefixes) & !is.null(prefixes)){
    prefixes=tibble::tibble(name=names(prefixes),
                            url=prefixes,
                            type="user")
  }
  if(auto==TRUE){
    prefixes_auto=usual_prefixes %>%
      filter(name %in% (query$prefixed %>% str_extract("^.*(?=:)"))) %>%
      filter(type!="Wikidata")
    prefixes=bind_rows(prefixes,prefixes_auto)
  }
  prefixes=prefixes %>%
    select(name,url) %>%
    unique()


  query$prefixes=bind_rows(query$prefixes,prefixes)
  return(query)
}
