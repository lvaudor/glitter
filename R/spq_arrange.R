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
spq_arrange = function(query , ..., replace = FALSE){

  ordering_variables <- purrr::map_chr(
    rlang::enquos(...),
    translate_sparql_arrange
  )

  query$order_by = if (replace) {
    ordering_variables
  } else {
    c(query$order_by, ordering_variables)
  }

  return(query)
}

translate_sparql_arrange <- function(x) {
  # Let users pass strings a la "DESC(?sitelinks)" directly
  maybe_sparql_string <- try(rlang::eval_tidy(x), silent = TRUE)
  if (is.spq(maybe_sparql_string)) {
    return(maybe_sparql_string)
  } else if (!inherits(maybe_sparql_string, "try-error")) {
    rlang::abort("Did you mean to pass a string? Use spq() to wrap it.")
  }

  desc <- function(x) {
    sprintf("DESC(%s)", rlang::enexpr(x)%>%rlang::as_label())
  }

  asc <- function(x) {
    sprintf("ASC(%s)", rlang::enexpr(x)%>%rlang::as_label())
  }

  arranging_expr <- rlang::get_expr(x)

  maybe_sparql_function_call <- try(
    rlang::eval_tidy(arranging_expr),
    silent = TRUE
  )


  if (inherits(maybe_sparql_function_call, "try-error")) {
    # bare variable name e.g. spq_arrange(location)
    sprintf("?%s", as.character(arranging_expr))
  } else {
    # desc(variable) or asc(variable), translated
    # add the ? to variable
    add_question_mark <- function(x) {sprintf("?%s", x)}
    stringr::str_replace(maybe_sparql_function_call, "[a-zA-Z0-9]+\\)*$", add_question_mark)
  }

}


