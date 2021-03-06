#' Get labels in a specified language (apply only to Wikidata)
#' @param .query the query
#' @param language the language in which the labels will be provided (defaults to "en" for English). See complete list of Wikimedia language codes [here](https://www.wikidata.org/wiki/Help:Wikimedia_language_codes/lists/all). You can also set language to "auto" and then the Wikidata SPARQL engine will try and detect your language automatically. Specifying several languages will return labels with languages following the priority specified (e.g. with language="fr,en", the label will be returned preferentially in French, or, if there is not French label for the item, in English).
#' @return A query object
#' @export
#' @examples
#' spq_init() %>%
#'  spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>%
#'  spq_language("fr,en") %>%
#'  spq_head(10)
#'
#' spq_init() %>%
#'  spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>%
#'  spq_language("auto,es,it,de") %>%
#'  spq_head(10)
spq_language = function(.query = NULL,
                      language = "en"){
  language=stringr::str_replace(language,"auto","[AUTO_LANGUAGE]")
  .query$service=paste0('SERVICE wikibase:label { bd:serviceParam wikibase:language "',
                       language,
                       '".}')
  return(.query)
}
