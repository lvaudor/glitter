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
  if(endpoint=="Wikidata"){
    tib <- quietly(WikidataQueryServiceR::query_wikidata)(query)$result
  }
  if(endpoint=="dataBNF"){
    tib <- SPARQL::SPARQL(url="https://data.bnf.fr/sparql",
                          query=query,
                          curl_args=list(useragent='User Agent Example'))
    tib <- tib$results
  }
  if(nrow(tib)==0){tib=NULL}
  return(tib)
}

