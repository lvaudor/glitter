#' Get coords at lat-lng from Wikidata format
#' @param data a tibble
#' @param coord_column the name of the column with coordinates formatted as 'Point(..... ....)'
#' @param prefix the prefix to be appended to "lat-lng" columns (defaults to "" -no prefix-)
#' @export
#' @examples
#' \dontrun{
#' spq_init() %>%
#'   spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
#'   spq_label(city) %>%
#'   spq_mutate(coords = wdt::P625(city),
#'           .within_distance=list(center=c(long=4.84,lat=45.76),
#'                                radius=5)) %>%
#'   spq_perform() %>%
#'   transform_wikidata_coords("coords")
#' }
transform_wikidata_coords = function(data,coord_column, prefix="") {
  handle_nas = function(x){
    if (is.na(x[1])) {
      x = c(NA,NA)
    }
    return(x)
  }

  result = data[[coord_column]] %>%
    str_extract_all("(?<=Point\\()[\\d\\.\\-\\s]*") %>%
    strsplit(" ") %>%
    purrr::map(handle_nas)

  lat = result %>%
    purrr::map_chr(purrr::pluck, 2) %>%
    as.numeric()
  lng = result %>%
    purrr::map_chr(purrr::pluck, 1) %>%
    as.numeric()
  tib_coords = tibble::tibble(lat=lat, lng=lng) %>%
    dplyr::rename_with(.fn = ~ paste0(prefix, .x))

  data %>%
    dplyr::select(-!!coord_column) %>%
    dplyr::bind_cols(tib_coords)
}
