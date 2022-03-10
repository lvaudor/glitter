#' Builds the "filter" part of a query.
#' @inheritParams spq_arrange
#' @export
#' @examples
#' # Corpus of articles with "wikidata" in the title
#' spq_init() %>%
#' spq_add("?item wdt:P31 wd:Q13442814") %>%
#' spq_add("?item rdfs:label ?itemTitle") %>%
#' spq_filter(str_detect(str_to_lower(itemTitle), 'wikidata')) %>%
#' spq_filter(lang(itemTitle)=="en") %>%
#' spq_head(n = 5)
spq_filter=function(query = NULL, ...){
  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  query$filter <- c(
    query$filter,
    sprintf("FILTER(%s)", variables)
  )

  return(query)
}
