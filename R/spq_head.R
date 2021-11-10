#' Return the first lines of results
#' @param query a list with elements of the query
#' @param n the maximum number of lines to return (defaults to 5)
#' @export
#' @examples
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?sitelinks") %>%
#' spq_arrange(c("DESC(?sitelinks)")) %>%
#' spq_head(n=3) %>%
#' send()
spq_head=function(query,n=5){
  query$limit=glue::glue("LIMIT {n}")
  return(query)
}
