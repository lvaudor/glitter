#' Select particular variables
#' @inheritParams spq_arrange
#' @export
#' @examples
#'
spq_select = function(query = NULL, ...){
  selected_variables <- purrr::map_chr(rlang::enquos(...), treat_select_argument)

  # add name for AS bla
  add_as <- function(string, name) {
    sprintf("%s AS %s", string, add_question_mark(name))
  }
  selected_variables[nzchar(names(selected_variables))] <- purrr::map2_chr(
    selected_variables[nzchar(names(selected_variables))],
    names(selected_variables)[nzchar(names(selected_variables))],
    add_as
  )

  minus_variables = selected_variables %>%
    stringr::str_subset("^\\-\\?") %>%
    stringr::str_remove("\\-")

  plus_variables = selected_variables %>%
    stringr::str_subset("^\\-\\?", negate = TRUE)

  query$select <- unique(c(query$select, plus_variables))
  query$select <- query$select[!query$select %in% minus_variables]
  return(query)
}

treat_select_argument <- function(arg) {
  eval_try <- try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  assert_whether_character(eval_try)
  code_data <- parse_code(rlang::as_label(arg))

  treat_symbol_function_call <- function(symbol_function_call) {
    equivalent <- all_correspondences[all_correspondences[["R"]] == xml2::xml_text(symbol_function_call), ]
    if (nrow(equivalent) > 0) {
      original_name <- xml2::xml_text(symbol_function_call)
      xml2::xml_text(symbol_function_call) <- equivalent[["SPARQL"]]
      xml2::xml_attr(symbol_function_call, "sparqlish") <- "true"

      sparql_arguments <- equivalent$args[[1]][[1]]
      expr <- xml2::xml_parent(xml2::xml_parent(symbol_function_call))
      r_arguments <- xml2::xml_find_all(expr, ".//SYMBOL_SUB")
      useless_arguments <- r_arguments[!xml2::xml_text(r_arguments) %in% na.omit(sparql_arguments[["R"]])]
      if (length(useless_arguments) > 0) {
        rlang::abort(
          sprintf(
            "Can't find equivalent for argument(s) %s for call to %s",
            toString(xml2::xml_text(useless_arguments)), original_name
          )
        )
      }
      replace_argument <- function(argument_node, sparql_arguments) {
        xml2::xml_text(argument_node) <- sparql_arguments[["SPARQL"]][sparql_arguments[["R"]] == xml2::xml_text(argument_node)]
      }
      purrr::walk(r_arguments, replace_argument, sparql_arguments = sparql_arguments)

      # Remove ,
      commas <- xml2::xml_find_all(expr, ".//OP-COMMA")
      xml2::xml_text(commas) <- ";"

    } else {
      xml2::xml_attr(symbol_function_call, "sparqlish") <- "false"
    }
  }
  symbol_function_calls <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL")

  purrr::walk(symbol_function_calls, treat_symbol_function_call)

  # then look for unique
  treat_unique <- function(symbol_function_call) {
    expr <- xml2::xml_parent(xml2::xml_parent(symbol_function_call))
    xml2::xml_text(symbol_function_call) <- "DISTINCT "
    xml2::xml_attr(symbol_function_call, "sparqlish") <- "true"
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-LEFT-PAREN"))
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-RIGHT-PAREN"))
  }
  unique_calls <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL[normalize-space(text()) = 'unique']")

  purrr::walk(unique_calls, treat_unique)

  # then add ?
  symbols <- xml2::xml_find_all(code_data, ".//SYMBOL")
  xml2::xml_text(symbols) <- add_question_mark(xml2::xml_text(symbols))

  # Abort if not sparqlish
  not_sparqlish <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL[@sparqlish='false']")
  if (length(not_sparqlish) > 0) {
    rlang::abort(
      sprintf(
        "Can't find equivalent for %s."),
      toString(
        purrr::map_chr(not_sparqlish, xml2::xml_text)
      )
    )
  }

  # put it back together
  text <- xml2::xml_text(code_data)
  gsub('[\"]', '"', text)
}
