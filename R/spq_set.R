#' Set helper values for the query
#'
#' @description Set helper values for the query (helps with readability)
#' @param query query
#' @param ... Helper values and their definition.
#'
#' @return
#' @export
#'
#' @examples
#' # find the individuals of the species
#' spq_init() %>%
#' # dog, cat or chicken
#' spq_set(species = c('wd:144','wd:146', 'wd:780'), mayor = "Q30185") %>%
#' spq_add(spq("?mayor wdt:P31 ?species"))
spq_set = function(query, ...) {
  args = rlang::enquos(...)

  subjects = names(args)
  values = purrr::map_chr(args, treat_value)
  new_triples = sprintf("VALUES ?%s %s", subjects, values)

  query$body <- paste(
    query$body,
    paste(new_triples, collapse = "\n"),
    sep = "\n"
  )

  # TODO: -select by default?
  return(query)
}

treat_value = function(value) {
  sprintf("{%s}", paste0(rlang::eval_tidy(value), collapse = " "))
}
