#' Builds the "limit" part of a query.
#' @param query a list with elements of the query
#' @param n the maximum number of lines to return (defaults to 5)
#' @export
#' @examples
#' add_triplets(s="?item",v="wdt:P31",o="wd:Q5",label="?item") %>%
#' add_triplets(s="?item",v="wdt:P19/wdt:P131*",o="wd:Q60") %>%
#' add_triplets(s="?item",v="wikibase:sitelinks",o="?sitelinks") %>%
#' spq_arrange(c("DESC(?sitelinks)")) %>%
#' spq_head(n=3) %>%
#' send()
spq_head=function(query,n=5){
  query$limit=glue::glue("LIMIT {n}")
  return(query)
}
