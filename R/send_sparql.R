#' Send SPARQL query to endpoint and get tibble as a result
#' @param query a string corresponding to a SPARQL query
#' @param endpoint a string or url corresponding to a SPARQL endpoint. Defaults to "Wikidata"
#' @export
#' @examples
#'metro_query='SELECT ?item ?itemLabel ?coords
#'{
#'  ?item wdt:P361 wd:Q1552;
#'  wdt:P625 ?coords.
#'  OPTIONAL{?item wdt:P1619 ?date.}
#'  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
#'} ORDER BY ?itemLabel
#''
#'send_sparql(query=metro_query)
#' @import SPARQL
send_sparql=function(query,endpoint="Wikidata"){
  endpoint=tolower(endpoint)

  # if endpoint wikidata, use WikidataQueryServiceR::query_wikidata()
  if(endpoint=="wikidata"){
    tib <- purrr::quietly(WikidataQueryServiceR::query_wikidata)(query)$result
  }
  # else, use SPARQL::SPARQL()
  # if endpoint passed as name, get url
  if(endpoint %in% (usual_endpoints %>%
                    dplyr::filter(.data$name!="wikidata") %>%
                    dplyr::pull(.data$name))){
    url=usual_endpoints %>%
      dplyr::filter(.data$name == {{ endpoint }}) %>%
      dplyr::select(.data$url) %>%
      dplyr::pull()
    tib <- SPARQL::SPARQL(url=url,
                          query=query,
                          curl_args=list(useragent='glitter R package (https://github.com/lvaudor/glitter)'))
    tib <- tib$results
  }
  # else, endpoint must be passed as url
  if(!(endpoint %in% usual_endpoints$name)){
    tib <- SPARQL::SPARQL(url=endpoint,
                          query=query,
                          curl_args=list(useragent='User Agent Example'))
    tib <- tib$results
  }
  # if returned table has 0 rows replace it with NULL (easier to bind with other results)
  if(nrow(tib)==0){tib=NULL}
  return(tib)
}

utils::globalVariables("usual_endpoints")
