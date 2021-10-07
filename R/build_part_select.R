#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param label whether to get the label associated with the mentioned item
build_part_select=function(query=NA,subject,verb,object,label=NA){
  if(!is.na(query[1])){
    part_select=query$select
  }else{
    part_select=c()
  }
  for(element in list(subject,verb,object)){
    if(is_variable(element)){
      part_select=c(part_select, element)
      if(element %in% label){
        part_select=c(part_select,paste0(element,"Label"))
      }
    }
  }
  part_select=unique(part_select)
  return(part_select)
}
