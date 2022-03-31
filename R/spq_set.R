#' Set helper values for the query
#'
#' @description Set helper values for the query (helps with readability)
#' @param .query query
#' @param ... Helper values and their definition.
#'
#' @return A query object
#' @export
#'
#' @section Some examples:
#'
#' ```r
#' # find the individuals of the species
#' spq_init() %>%
#' # dog, cat or chicken
#' spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780'), mayorcode = "wd:Q30185") %>%
#' spq_filter(mayor == wdt::P31(species), .label = "?species") %>%
#' spq_add("?mayor p:P39 ?node", .label = "?mayor") %>%
#' # of mayor
#' spq_add("?node ps:P39 ?mayorcode") %>%
#' # of some places
#' spq_add("?node pq:P642 ?place", .label = "?place") %>%
#' spq_select(-species, -place, -node, -mayor, -mayorcode) %>%
#' spq_perform()
#' ```
spq_set = function(.query, ...) {
  args = rlang::enquos(...)

  subjects = names(args)
  values = purrr::map_chr(args, treat_value)
  new_triples = sprintf("VALUES ?%s %s", subjects, values)

  .query$body <- paste(
    .query$body,
    paste(new_triples, collapse = "\n"),
    sep = "\n"
  )

  # TODO: -select by default?
  return(.query)
}

treat_value = function(value) {
  sprintf("{%s}", paste0(rlang::eval_tidy(value), collapse = " "))
}
