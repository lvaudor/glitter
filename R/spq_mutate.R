#' Create and modify variables in the results
#' @inheritParams spq_arrange
#' @export
#' @examples
#' # common name of a plant species in different languages
#' spq_init() %>%
#' spq_add("wd:Q331676 wdt:P1843 ?statement") %>%
#' spq_mutate(lang = lang(statement))
spq_mutate = function(.query, ...){
  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  .query$select <- unique(c(.query$select, variables))
  return(.query)
}
