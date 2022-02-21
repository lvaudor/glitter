#' Group the results by one or more variables
#' @param query a list with elements of the query
#' @param vars a vector with the names of the variables used for grouping
#' @export
#' @examples
#' \dontrun{
#' spq_init() %>%
#' spq_add("?s a ?class") %>%
#' spq_group_by("?class") %>%
#' spq_head(n=3) %>%
#' spq_perform()
#' }
spq_group_by=function(query,vars){
  varformula=get_varformula(query$select)
  query$select=varformula %>%
    dplyr::filter(.data$name %in% vars) %>%
    dplyr::pull(.data$full)
  query$group_by=varformula %>%
    dplyr::filter(.data$name %in% {{ vars }}) %>%
    dplyr::pull(.data$formula)
  return(query)
}
