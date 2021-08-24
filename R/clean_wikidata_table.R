#' Clean Wikidata results by removing the "http://www.wikidata.org/entity/" prefix in all columns
#' @param wikitib a Wikidata results tibble
#' @export
#' @examples
#'metro_query='SELECT ?item ?itemLabel ?coords
#'{
#'  ?item wdt:P361 wd:Q1552;
#'  wdt:P625 ?coords .
#'  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
#'} ORDER BY ?itemLabel
#''
#'tib=send_sparql(query=metro_query)
#'clean_tib=clean_wikidata_table(tib)
#'clean_tib %>% head()
clean_wikidata_table=function(wikitib){
  result=wikitib %>%
    dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                  stringr::str_replace,
                  pattern="http://www.wikidata.org/entity/",
                  replacement="wd:"))
  return(result)
}
