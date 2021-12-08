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
  varformula=glitter:::get_varformula(query$select)
  query$select=varformula %>%
    filter(name %in% vars) %>%
    pull(full)
  query$group_by=varformula %>%
    filter(name %in% vars) %>%
    pull(formula)
  return(query)
}
