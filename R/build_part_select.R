#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param label whether to get the label associated with the mentioned item
#' @noRd
build_part_select=function(query=NULL,subject=NULL,verb=NULL,object=NULL,label=NA){

  part_select=query$select

  for(element in list(subject,verb,object)){
    # when element is a variable, add it to SELECT list
    if(is_variable(element)){
      part_select=c(part_select, element)
      # when ?xxx is mentioned in argument `label`, add ?xxxLabel
      if(element %in% label){
        part_select=c(part_select,paste0(element,"Label"))
      }
    }
  }
  # return all selected variables (as a character vector)
  part_select=unique(part_select)
  return(part_select)
}
