#' Arrange results by variable value
#' @param query a list with elements of the query
#' @param vars variables by which to arrange
#' @export
#' @examples
#' tib=spq_init() %>%
#' add_triplets("?item wdt:P31 wd:Q5",label="?item") %>%
#' add_triplets("?item wdt:P19/wdt:P131* wd:Q60") %>%
#' add_triplets("?item wikibase:sitelinks ?sitelinks") %>%
#' spq_arrange(c("DESC(?sitelinks)")) %>%
#' spq_head(n=3) %>%
#' send()
spq_arrange=function(query,vars){
  vars=vars %>%
    paste(collapse=" ")
  query$order_by=glue::glue("ORDER BY {vars}")
  return(query)
}
