#' Create and modify variables in the results
#' @inheritParams spq_arrange
#' @export
#' @examples
#' # common name of a plant species in different languages
#' spq_init() %>%
#' spq_add("wd:Q331676 wdt:P1843 ?statement") %>%
#' spq_mutate(lang = lang(statement))
spq_mutate = function(query, ...){
    selected_variables = purrr::map_chr(rlang::enquos(...), treat_select_argument)

  # add name for AS bla
  add_as = function(string, name) {
    sprintf("(%s AS %s)", string, add_question_mark(name))
  }
  selected_variables[nzchar(names(selected_variables))] = purrr::map2_chr(
    selected_variables[nzchar(names(selected_variables))],
    names(selected_variables)[nzchar(names(selected_variables))],
    add_as
  )

  query$select <- unique(c(query$select, selected_variables))
  return(query)
}
