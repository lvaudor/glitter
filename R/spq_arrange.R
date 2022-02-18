#' Arrange results by variable value
#' @param query a list with elements of the query
#' @param ... variables by which to arrange (or SPARQL strings escaped with `spq()`, see examples)
#' @param replace whether to replace the pre-existing arranging
#' @export
#' @examples
#' # descending length, ascending itemLabel, "R" syntax
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length), itemLabel) %>%
#'   spq_head(50)
#'
#' # descending length, ascending itemLabel, SPARQL syntax
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", label = c("?item")) %>%
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
#'   spq_filter("xsd:integer(?mort)<'1924'^^xsd:integer") %>%
#'   spq_group_by(c("?auteur","?nom","?mort")) %>%
#'   spq_arrange(desc(xsd:integer(mort)))
#'
#' # descending xsd:integer(mort), SPARQL syntax
#' spq_init() %>%
#'   spq_add("?oeuvre dcterms:creator ?auteur") %>%
#'   spq_add("?auteur bio:death ?mort") %>%
#'   spq_add("?auteur foaf:familyName ?nom") %>%
#'   spq_filter("xsd:integer(?mort)<'1924'^^xsd:integer") %>%
#'   spq_group_by(c("?auteur","?nom","?mort")) %>%
#'   spq_arrange(spq("DESC(xsd:integer(?mort))"))
#'
#' # Usage of the replace argument
#' # replace = FALSE (default)
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length)) %>%
#'   spq_arrange(location) %>%
#'   spq_head(50)
#'
#' # replace = TRUE
#' spq_init() %>%
#'   spq_add("?item wdt:P31/wdt:P279* wd:Q4022", label = c("?item")) %>%
#'   spq_add("?item wdt:P2043 ?length") %>%
#'   spq_add("?item wdt:P625 ?location") %>%
#'   spq_arrange(desc(length)) %>%
#'   spq_arrange(location, replace = TRUE) %>%
#'   spq_head(50)
spq_arrange = function(query , ..., replace = FALSE){
  ordering_variables <- purrr::map_chr(
    rlang::enquos(...),
    treat_argument
  )

  query$order_by = if (replace) {
    ordering_variables
  } else {
    c(query$order_by, ordering_variables)
  }
  query
}



treat_argument <- function(arg) {

  eval_try <- try(rlang::eval_tidy(arg), silent = TRUE)
  is_spq <- is.spq(eval_try)

  if (is_spq) {
    return(eval_try)
  }

  if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    rlang::abort("Did you mean to pass a string? Use spq() to wrap it.")
  }

  desc <- function(x) {
    sprintf("DESC(%s)", rlang::enexpr(x) %>% rlang::as_label())
  }

  asc <- function(x) {
    sprintf("ASC(%s)", rlang::enexpr(x) %>% rlang::as_label())
  }

  add_question_mark <- function(x) sprintf("?%s", x)

  arranging_expr <- rlang::get_expr(arg)

  need_uppercase_translation <- grepl("^(desc|asc)\\(", rlang::as_label(arranging_expr))

  arranging_expr = if (need_uppercase_translation) {
    # desc(variable) or asc(variable), translated
    # add the ? to variable (variable = most nested thing)
    rlang::eval_tidy(arranging_expr)
  } else {
    rlang::as_label(arranging_expr)
  }

  stringr::str_replace(
    arranging_expr,
    "[a-zA-Z0-9]+\\)*$",
    add_question_mark
  ) %>% spq()

}

