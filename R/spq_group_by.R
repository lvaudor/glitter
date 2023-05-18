#' Group the results by one or more variables
#' @param .query query
#' @param ... Either R-DSL or strings with variable names
#' @return A query object
#' @export
#' @examples
#' spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114", .label = "?area") %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(area, areaLabel)  %>%
#' spq_summarise(total_folkm = sum(folkm_ngd))
spq_group_by = function(.query, ...){
  vars = purrr::map_chr(rlang::enquos(...), spq_treat_argument)
  varformula = purrr::map_df(.query$select, get_varformula)
  .query$select = varformula %>%
    dplyr::filter(.data$name %in% vars) %>%
    dplyr::pull(.data$full)
  .query$group_by = varformula %>%
    dplyr::filter(.data$name %in% {{ vars }}) %>%
    dplyr::pull(.data$formula)
  return(.query)
}
