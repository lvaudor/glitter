#' Return the first lines of results
#' @param .query a list with elements of the query
#' @param n the maximum number of lines to return
#' @export
#' @examples
#' # Return the default of 5 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",.label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?linkcount") %>%
#' spq_arrange(desc(linkcount)) %>%
#' spq_head()
#'
#' # Return 42 items
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q5",.label="?item") %>%
#' spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' spq_add("?item wikibase:sitelinks ?linkcount") %>%
#' spq_arrange(desc(linkcount)) %>%
#' spq_head(42)
#' @inheritSection spq_offset Subsetting
spq_head = function(.query, n = 5){
  .query$limit = n
  return(.query)
}
