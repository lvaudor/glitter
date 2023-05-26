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

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  names(variables[!nzchar(names(variables))]) <- variables[!nzchar(names(variables))]

  no_grouping <- is.null(.query$group_by)
  if (no_grouping) {
    .query$group_by = names(variables)
    .query$select = NULL
  }

  .query$select = c(.query$select, variables)
  return(.query)
}

#' @export
#' @rdname spq_summarise
spq_summarize <- spq_summarise
