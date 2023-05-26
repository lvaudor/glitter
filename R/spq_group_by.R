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
spq_group_by = function(.query, ...) {
  vars = purrr::map_chr(rlang::enquos(...), spq_treat_argument)
  varformula = purrr::map_df(.query$select, get_varformula)

  # if group_by variables are defined in select
  # then we don't need to add them to the select
  # example: (year(?bla) as year) and group by year
  custom_groupies <- varformula[varformula[["name"]] %in% vars,][["full"]]
  .query[["select"]] <- unique(
    c(
      .query[["select"]],
      custom_groupies,
      vars[!(vars %in% varformula[["name"]])]
      )
    )

  .query[["group_by"]] = vars
  return(.query)
}
