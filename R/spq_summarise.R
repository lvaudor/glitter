#' Summarise each group of results to fewer results
#' @inheritParams spq_arrange
#' @return A query object
#' @export
#' @examples
#' result = spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114", .label = "?area") %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(area, areaLabel)  %>%
#' spq_summarise(total_folkm = sum(folkm_ngd))
spq_summarise = function(.query, ...) {

  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)
  are_we_tallying <- ("COUNT(*)" %in% variables)

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  names(variables[!nzchar(names(variables))]) <- variables[!nzchar(names(variables))]
  if (are_we_tallying) {
    .query$select = variables
    return(.query)
  }

  for (var in variables) {
    .query = spq_select(.query, spq(var))

    formula_df = get_varformula(var)
    .query = track_vars(
      .query = .query,
      name = sprintf("?%s", names(variables)[variables == var]),
      formula = var,
      ancestor = formula_df[["args"]][[1]],
      fun = sub("\\)$", "", sub("\\(.*", "", formula_df[["formula"]]))
    )

  }
  .query[["select"]] <- c(.query[["group_by"]], variables)
  return(.query)
}

#' @export
#' @rdname spq_summarise
spq_summarize <- spq_summarise
