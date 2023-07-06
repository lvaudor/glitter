#' Arrange results by variable value
#' @param .query a list with elements of the query
#' @param ... variables by which to arrange
#' (or SPARQL strings escaped with `spq()`, or strings, see examples)
#' @param .replace whether to replace the pre-existing arranging
#' @return A query object
#' @export
#' @examples
#' # descending length, ascending itemLabel, "R" syntax
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length), itemLabel) %>%
#'   spq_head(50)
#'
#' # descending length, ascending itemLabel, "R" syntax with quotes e.g. for a loop
#' variable = "length"
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(sprintf("desc(%s)", variable), itemLabel) %>%
#'   spq_head(50)
#'
#' # descending length, ascending itemLabel, SPARQL syntax
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(spq("DESC(?length) ?itemLabel")) %>%
#'   spq_head(50)
#'
#' # descending xsd:integer(mort), R syntax
#' spq_init() %>%
#'   spq_add("?oeuvre dcterms:creator ?auteur") %>%
#'   spq_add("?auteur bio:death ?mort") %>%
#'   spq_add("?auteur foaf:familyName ?nom") %>%
#'   spq_filter(as.integer(mort) < as.integer("1924")) %>%
#'   spq_group_by(auteur, nom, mort) %>%
#'   spq_arrange(desc(as.integer(mort)))
#'
#' # descending as.integer(mort), SPARQL syntax
#' spq_init() %>%
#'   spq_add("?oeuvre dcterms:creator ?auteur") %>%
#'   spq_add("?auteur bio:death ?mort") %>%
#'   spq_add("?auteur foaf:familyName ?nom") %>%
#'   spq_filter(as.integer(mort) < as.integer("1924")) %>%
#'   spq_group_by(auteur, nom, mort) %>%
#'   spq_arrange(spq("DESC(xsd:integer(?mort))"))
#'
#' # Usage of the .replace argument
#' # .replace = FALSE (default)
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length)) %>%
#'   spq_arrange(location) %>%
#'   spq_head(50)
#'
#' # .replace = TRUE
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length)) %>%
#'   spq_arrange(location, .replace = TRUE) %>%
#'   spq_head(50)
#'
#' # Mixing syntaxes
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", .label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length), spq("?location")) %>%
#'   spq_head(50)
spq_arrange = function(.query, ..., .replace = FALSE) {
  ordering_patterns = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  if (.replace) {
    .query[["structure"]][["ordering"]] <- "none"
  }

  # track ordering in structure df ----
  if (!is.null(.query[["vars"]])) {
    ordering_variables = purrr::map_df(ordering_patterns, handle_arrange_pattern) %>%
      dplyr::filter(name %in%.query[["vars"]][["name"]])
  } else {
    # in tests
    ordering_variables = purrr::map_df(ordering_patterns, handle_arrange_pattern)
  }

  purrr::reduce2(
    ordering_variables[["name"]],
    ordering_variables[["ordering"]],
    function(query, x, y) track_structure(query, name = x, ordering = y),
    .init = .query
  )
}

handle_arrange_pattern = function(pattern) {
  name = sub(".*\\?", "?", sub("\\)$", "", pattern))
  ordering = if (grepl("^DESC", pattern)) {
    "desc"
  } else {
    "asc"
  }

  tibble::tibble(name = name, ordering = ordering)
}
