#' Group the results by one or more variables
#' @param .query query
#' @param ... Either R-DSL or strings with variable names
#' @export
#' @examples
#' \dontrun{
#' spq_init() %>%
#' spq_add("?s a ?class") %>%
#' spq_group_by(class) %>%
#' spq_head(n=3) %>%
#' spq_perform()
#' }
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
