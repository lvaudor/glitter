#' Select (and create) particular variables
#' @inheritParams spq_arrange
#' @param .spq_duplicate How to handle duplicates: keep them (`NULL`), eliminate (`distinct`)
#' or reduce them (`reduced`, advanced usage).
#' @export
#' @examples
#'
#' query = spq_init()
#' spq_select(query, count = n (human), eyecolorLabel, haircolorLabel)
spq_select = function(query = NULL, ..., .spq_duplicate = NULL){
  if (!is.null(.spq_duplicate)) {
    original_spq_duplicate <- .spq_duplicate
    .spq_duplicate <- toupper(.spq_duplicate)
    if (!(spq_duplicate %in% c("DISTINCT", "REDUCED"))) {
      rlang::abort(c(
        x = sprintf("Wrong value for `.spq_duplicate` argument (%s).", original_spq_duplicate),
        i = 'Use either `NULL`, "distinct" or "reduced".'
      )
      )
    }
  }
  query$spq_duplicate <- .spq_duplicate

  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  minus_variables = variables %>%
    stringr::str_subset("^\\-\\?") %>%
    stringr::str_remove("\\-")

  plus_variables = variables %>%
    stringr::str_subset("^\\-\\?", negate = TRUE)

  query$select = unique(c(query$select, plus_variables))
  query$select = query$select[!query$select %in% minus_variables]
  return(query)
}
