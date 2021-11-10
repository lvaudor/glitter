#' Group the results by one or more variables
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' spq_init() %>%
#' spq_add("?s a ?class") %>%
#' spq_group_by("?class") %>%
#' spq_head(n=3) %>%
#' send()
spq_group_by=function(query,vars){
  vars=paste0(vars,collapse=" ")
  new_select=glue::glue("DISTINCT {vars}")
  query$select=new_select
  return(query)
}
