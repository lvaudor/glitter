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
#'tib=send_sparql(metro_query)
#'clean_tib=clean_wikidata_table(tib)
#'clean_tib %>% head()
clean_wikidata_table=function(wikitib){
  result=wikitib %>%
    # https://github.com/r-lib/tidyselect/issues/201 regarding using where
    dplyr::mutate(dplyr::across(where(is.character),
                  str_replace,
                  pattern="http://www.wikidata.org/entity/",
                  replacement="wd:"))
  return(result)
}
utils::globalVariables("where")
