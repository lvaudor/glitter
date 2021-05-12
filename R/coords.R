#' Get coords at lat-lng from Wikidata format
#' @param data a tibble
#' @param coord_column the name of the column with coordinates formatted as 'Point(..... ....)'
#' @param prefix the prefix to be appended to "lat-lng" columns (defaults to "" -no prefix-)
#' @export
#' @examples
#' query='SELECT ?item ?itemLabel ?coords ?date
#' {
#'   ?item wdt:P361 wd:Q1552;
#'         wdt:P625 ?coords.
#'   OPTIONAL{?item wdt:P1619 ?date.}
#'   SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
#' } ORDER BY ?itemLabel
#' '
#' tib=send_sparql(query)
#' transform_wikidata_coords(tib, "coords")
transform_wikidata_coords=function(data,coord_column, prefix=""){
  result=data[[coord_column]] %>%
    stringr::str_extract("(?<=Point\\()[\\d\\.\\-\\s]*") %>%
    stringr::str_split(" ")
  lat=result %>%
    purrr::map_chr(purrr::pluck,2) %>%
    as.numeric()
  lng=result %>%
    purrr::map_chr(purrr::pluck,1) %>%
    as.numeric()
  tib_coords=tibble(lat=lat,
                    lng=lng) %>%
    dplyr::rename_with(.fn = ~ paste0(prefix, .x))
  tib_result=data %>%
    dplyr::select(-!!coord_column) %>%
    dplyr::bind_cols(tib_coords)
  return(tib_result)
}
