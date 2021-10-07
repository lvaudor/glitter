
#' Builds the "filter" part of a query.
#' @param query a list with elements of the query*
#' @param expressions the vector of filtering expressions to apply
build_part_filter=function(query=NA, expressions){
  if(!is.na(query[1])){
    part_filter=query$filter
  }else{
    part_filter=c()
  }
  if(!is.na(expressions)){
    part_filter_to_add=paste0("FILTER(",expressions,")\n")%>%
      paste0(collapse="")
    part_filter=paste0(part_filter,part_filter_to_add)
  }else{
    part_filter=part_filter
  }

  return(part_filter)
}
