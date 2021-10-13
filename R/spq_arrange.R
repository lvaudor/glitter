#' Builds the "order by" part of a query.
#' @param query a list with elements of the query
#' @param vars variables by which to arrange
#' @export
#' @examples
#' add_triplets(s="?item",v="wdt:P31",o="wd:Q5", limit=3, label="?item") %>%
#' add_triplets(s="?item",v="wdt:P19/wdt:P131*",o="wd:Q60") %>%
#' add_triplets(s="?item",v="wikibase:sitelinks",o="?sitelinks") %>%
#' spq_arrange(c("DESC(?sitelinks)")) %>%
#' send()
spq_arrange=function(query,vars){
  vars=vars %>%
    paste(collapse=" ")
  query$order_by=glue::glue("ORDER BY {vars}")
  return(query)
}
