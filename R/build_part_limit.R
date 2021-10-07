#' Builds the "limit" part of a query.
#' @param query a list with elements of the query
build_part_limit=function(query,limit=NA){
  if(!is.na(query[1])){
    part_limit=query$limit
  }else{
    if(is.na(limit)){
      part_limit=""}
    else{
      part_limit=glue::glue("LIMIT {as.character(limit)}")
    }
  }
  return(part_limit)
}
