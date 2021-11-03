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
send_sparql=function(query,endpoint="Wikidata"){
  endpoint=tolower(endpoint)
  endpoints=tibble::tibble(name=c("databnf",
                                  "symogih",
                                  "isidore",
                                  "hal"),
                           url=c("https://data.bnf.fr/sparql",
                                 "http://bhp-publi.ish-lyon.cnrs.fr:8888/sparql",
                                 "https://isidore.science/sparql",
                                 "http://sparql.archives-ouvertes.fr/sparql"))
  # if endpoint wikidata, use WikidataQueryServiceR::query_wikidata()
  if(endpoint=="wikidata"){
    tib <- quietly(WikidataQueryServiceR::query_wikidata)(query)$result
  }
  # else, use SPARQL::SPARQL()
  # if endpoint passed as name, get url
  if(endpoint %in% endpoints$name){
    url=endpoints %>%
      dplyr::filter(name==endpoint) %>%
      dplyr::select(url) %>%
      pull()
    tib <- SPARQL::SPARQL(url=url,
                          query=query,
                          curl_args=list(useragent='User Agent Example'))
    tib <- tib$results
  }
  # else, endpoint must be passed as url
  if(!(endpoint %in% c("wikidata",endpoints$name))){
    tib <- SPARQL::SPARQL(url=endpoint,
                          query=query,
                          curl_args=list(useragent='User Agent Example'))
    tib <- tib$results
  }
  # if returned table has 0 rows replace it with NULL (easier to bind with other results)
  if(nrow(tib)==0){tib=NULL}
  return(tib)
}

