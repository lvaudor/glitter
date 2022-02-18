#' Return the first lines of results
#' @param query a list with elements of the query
#' @param n the maximum number of lines to return
#' @export
#' @examples
#' # Return the default of 5 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?sitelinks") %>%
#' spq_arrange(desc(siteLinks)) %>%
#' spq_head()
#'
#' # Return 42 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?sitelinks") %>%
#' spq_arrange(desc(siteLinks)) %>%
#' spq_head(n=42)
spq_head=function(query,n=5){
  query$limit=glue::glue("LIMIT {n}")
  return(query)
}
