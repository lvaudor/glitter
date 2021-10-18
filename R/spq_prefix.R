#' Builds the "prefixes" part of a query.
#' @param query a list with elements of the query
#' @param prefixes a vector of prefixes
#' @export
spq_prefix=function(query=NULL,auto=TRUE, prefixes=NULL){
  if(!is.data.frame(prefixes)){
    prefixes=tibble::tibble(name=names(prefixes),
                            url=prefixes)
  }
  if(auto){
    prefixes_auto=usual_prefixes %>%
      filter(name %in% (query$uris %>% str_extract("^.*(?=:)")))
    prefixes=bind_rows(prefixes,prefixes_auto)
  }
  query$prefixes=prefixes %>% unique()
  return(query)
}
