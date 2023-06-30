#' Group the results by one or more variables
#' @param .query query
#' @param ... Either R-DSL or strings with variable names
#' @return A query object
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

  for (var in vars) {
    .query <- track_structure(.query, name = var, grouping = TRUE)
  }

  return(.query)
}
