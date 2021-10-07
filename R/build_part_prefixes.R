#' Builds the "prefixes" part of a query.
#' @param query a list with elements of the query
#' @param prefixes
#' @export
build_part_prefixes=function(query=NA, prefixes=NULL){
  if(!is.na(query[1])){
    part_prefixes=query$prefixes
  }else{
    part_prefixes=""
  }
  if(length(prefixes)>0){
    new_prefixes=glue::glue("PREFIX {names(prefixes)}: <{prefixes}>")
    new_prefixes=paste0(new_prefixes,collapse="\n")
    part_prefixes=glue::glue("{part_prefixes} \n {new_prefixes}")
  }
  return(part_prefixes)
}
