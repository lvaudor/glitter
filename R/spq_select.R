#' Select (and create) particular variables
#' @inheritParams spq_arrange
#' @param .spq_duplicate How to handle duplicates: keep them (`NULL`),
#' eliminate (`distinct`)
#' or reduce them (`reduced`, advanced usage).
#' @return A query object
#' @export
#' @examples
#'
#' spq_init() |>
#'   spq_prefix(prefixes = c(dct = "http://purl.org/dc/terms/")) |>
#'   spq_add(spq('?lexemeId dct:language wd:Q1860')) |>
#'   spq_add(spq("?lexemeId wikibase:lemma ?lemma")) |>
#'   spq_filter(str_detect(lemma, '^pota.*')) |>
#'   spq_select(- lemma)
#'
#' spq_init() |>
#'   spq_prefix(prefixes = c(dct = "http://purl.org/dc/terms/")) |>
#'   spq_add(spq('?lexemeId dct:language wd:Q1860')) |>
#'   spq_add(spq("?lexemeId wikibase:lemma ?lemma")) |>
#'   spq_filter(str_detect(lemma, '^pota.*')) |>
#'   spq_select(lemma)
spq_select = function(.query = NULL, ..., .spq_duplicate = NULL) {
  if (!is.null(.spq_duplicate)) {
    original_spq_duplicate = .spq_duplicate
    .spq_duplicate = toupper(.spq_duplicate)
    if (!(.spq_duplicate %in% c("DISTINCT", "REDUCED"))) {
      cli::cli_abort(c(
        x = "Wrong value for {.arg .spq_duplicate} argument ({original_spq_duplicate}).",
        i = 'Use either `NULL`, "distinct" or "reduced".'
      )
      )
    }
  }
  .query[["spq_duplicate"]] = .spq_duplicate

  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  plus_variables = variables %>%
    str_subset("^\\-\\?", negate = TRUE)

  if (length(plus_variables) > 0) {

    check_variables_present(.query, plus_variables, call = rlang::caller_env())

    if (is.data.frame(.query[["structure"]])) {
      .query[["structure"]][["selected"]] = FALSE
    }

    .query = purrr::reduce(
      plus_variables,
      \(.query, var) track_structure(.query, name = var, selected = TRUE),
      .init = .query
    )
  }

  minus_variables = variables %>%
    str_subset("^\\-\\?") %>%
    str_remove("\\-")

  if (length(minus_variables) > 0) {
    check_variables_present(.query, minus_variables, call = rlang::caller_env())

    .query = purrr::reduce(
      minus_variables,
      \(.query, var) track_structure(.query, name = var, selected = FALSE),
      .init = .query
    )
  }

  return(.query)
}

check_variables_present <- function(query, variables, call) {

  if (nzchar(Sys.getenv("GLITTER.TESTING.SELECT"))) {
    return()
  }

  absent_variables <- setdiff(variables, query[["vars"]][["name"]])

  if (length(absent_variables) > 0) {
    cli::cli_abort(c(
      "Can't use {.fun spq_select} on absent variables: {toString(absent_variables)}.",
      i = "Did you forget a call to {.fun spq_add}, {.fun spq_mutate} or {.fun spq_label}?"
    ), call = call)
  }
}
