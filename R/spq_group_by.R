#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' add_triplets(s="?s",v="a",o="?class", limit=3) %>%
#' spq_group_by("?class") %>%
#' send()
spq_group_by=function(query,vars){
  vars=paste0(vars,collapse=" ")
  new_select=glue::glue("DISTINCT {vars}")
  query$select=new_select
  return(query)
}
