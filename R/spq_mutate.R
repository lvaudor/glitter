#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param name name of variable
#' @param description formula
#' @export
#' @examples
#' add_triplets(s="wd:Q331676",v="wdt:P1843",o="?statement") %>%
#' spq_mutate(c("?lang"="LANG(?statement)")) %>%
#' send()
spq_mutate=function(query,vars){
  former_select=query$select
  vars=glue::glue("({vars} AS {names(vars)})") %>%
    paste(collapse=" ")
  new_select=glue::glue("{former_select} {vars}")
  query$select=new_select
  return(query)
}
