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

  varformula = purrr::map_df(.query[["select"]], get_varformula)

  vars_selected = intersect(vars, varformula[["name"]])
  vars_formulaed <- dplyr::filter(
    varformula,
    .data$name %in% vars_selected,
    .data$name != .data$formula
  )
  vars_asis <- setdiff(vars, vars_formulaed)

  if (nrow(vars_formulaed) == 0) {
    .query[["select"]] = union(.query[["select"]], vars)
    .query[["group_by"]] = vars
  } else {
    .query[["select"]] <- union(
      .query[["select"]][!(.query[["select"]] %in% vars_formulaed[["full"]])],
      vars
    )
    .query[["select"]] <- setdiff(
      .query[["select"]],
      unlist(varformula[varformula[["name"]] %in% vars,][["args"]])
    )
    .query[["select"]] <- unique(.query[["select"]])

    .query[["group_by"]] <- vars

    binded <- sprintf("BIND%s", vars_formulaed[["full"]]) %>% paste(collapse = "\n")
    .query[["body"]] <- paste(c(.query[["body"]], binded), collapse = "\n")
  }


  return(.query)
}
