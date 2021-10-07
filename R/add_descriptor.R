#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param name name of variable
#' @param description formula
#' @export
#' @examples
#' add_triplets(subject="wd:Q331676",verb="wdt:P1843",object="?statement") %>%
#' add_descriptor(name="?lang", formula="LANG(?statement)") %>%
#' build_sparql() %>%
#' send_sparql()
add_descriptor=function(query,name,formula){
  former_select=query$select
  new_select=glue::glue("{former_select} ({formula} as {name})")
  query$select=new_select
  return(query)
}
