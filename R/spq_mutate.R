#' Create and modify variables in the results
#' @param query a list with elements of the query
#' @param name name of variable
#' @param description formula
#' @export
#' @examples
#' # common name of a plant species in different languages
#' spq_init() %>%
#' spq_add("wd:Q331676 wdt:P1843 ?statement") %>%
#' spq_mutate(c("?lang"="LANG(?statement)")) %>%
#' send()
spq_mutate=function(query,vars){
  former_select=query$select
  vars=glue::glue("({vars} AS {names(vars)})") %>%
    paste(collapse=" ")
  new_select=c(former_select,vars)
  query$select=new_select
  return(query)
}
