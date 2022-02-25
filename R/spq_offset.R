#' Offset the first generated result
#' @param query a list with elements of the query
#' @param n the maximum number of lines to return
#' @export
#' @section Subsetting:
#' [`spq_offset()`] and [`spq_limit()`] are only useful when used with
#' [`spq_arrange()`] that makes the order of results predictable.
#' @examples
#' # Return 42 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?linkcount") %>%
#' spq_arrange(desc(linkcount)) %>%
#' spq_head(n=42)
#'
#' # Return 42 items after the first 11 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?linkcount") %>%
#' spq_arrange(desc(linkcount)) %>%
#' spq_head(42) %>%
#' spq_offset(11)
spq_offset = function(query, n = 5){
  query$offset = n
  return(query)
}
