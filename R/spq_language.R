#' Get labels in a specified language (apply only to Wikidata)
#' @param query the query
#' @param language the language in which the labels will be provided (defaults to "en" for English)
#' @export
#' @examples
#' tib=spq_init() %>%
#'  spq_add("?film wdt:P31 wd:Q11424", label="?film") %>%
#'  spq_add("?film wdt:P840 ?loc", label="?loc") %>%
#'  spq_add("?film wdt:P495 ?origin", label="?origin") %>%
#'  spq_add("?film wdt:P577 ?date") %>%
#'  spq_mutate(c("?year"="year(?date)")) %>%
#'  spq_language("fr") %>%
#'  spq_head(10) %>%
#'  spq_select("-?date") %>%
#'  send()
spq_language=function(query=NULL,
                      language="en"){
  query$service=paste0('SERVICE wikibase:label { bd:serviceParam wikibase:language "',
                       language,
                       '".}')
  return(query)
}
