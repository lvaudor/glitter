#' Select (and create) particular variables
#' @inheritParams spq_arrange
#' @param spq_duplicate How to handle duplicates: keep them (`NULL`), eliminate (`distinct`)
#' or reduce them (`reduced`, advanced usage).
#' @export
#' @examples
#'
#' query = spq_init()
#' spq_select(query, count = n (human), eyecolorLabel, haircolorLabel)
spq_select = function(query = NULL, ..., spq_duplicate = NULL){
  if (!is.null(spq_duplicate)) {
    original_spq_duplicate <- spq_duplicate
    spq_duplicate <- toupper(spq_duplicate)
    if (!(spq_duplicate %in% c("DISTINCT", "REDUCED"))) {
      rlang::abort(c(
        x = sprintf("Wrong value for `spq_duplicate` argument (%s).", original_spq_duplicate),
        i = 'Use either `NULL`, "distinct" or "reduced".'
      )
      )
    }
  }
  query$spq_duplicate <- spq_duplicate

  variables = purrr::map_chr(rlang::enquos(...), treat_select_argument)

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

treat_select_argument = function(arg) {
  eval_try = try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  assert_whether_character(eval_try)

  code_data = parse_code(rlang::as_label(arg))

  treat_symbol_function_call = function(symbol_function_call) {
    equivalent = all_correspondences[all_correspondences[["R"]] == xml2::xml_text(symbol_function_call), ]

    if (nrow(equivalent) > 0) {
      original_name = xml2::xml_text(symbol_function_call)
      xml2::xml_text(symbol_function_call) = equivalent[["SPARQL"]]
      xml2::xml_attr(symbol_function_call, "sparqlish") = "true"

      expr = xml2::xml_parent(xml2::xml_parent(symbol_function_call))

      # Argument names
      sparql_arguments = equivalent$args[[1]]
      if (length(sparql_arguments) > 0) {
        sparql_arguments = sparql_arguments[[1]]
      } else {
        sparql_arguments = NULL
      }
      r_arguments = xml2::xml_find_all(expr, ".//SYMBOL_SUB")
      useless_arguments = r_arguments[!xml2::xml_text(r_arguments) %in% stats::na.omit(sparql_arguments[["R"]])]
      if (length(useless_arguments) > 0) {
        rlang::abort(
          c(
            x = sprintf(
              "Can't find equivalent for argument(s) %s for call to %s().",
              toString(xml2::xml_text(useless_arguments)), original_name
            ),
            i = "If you think there should be one, open an issue in https://github.com/lvaudor/glitter."
          )
        )
      }
      replace_argument = function(argument_node, sparql_arguments) {
        xml2::xml_text(argument_node) = sparql_arguments[["SPARQL"]][sparql_arguments[["R"]] == xml2::xml_text(argument_node)]
      }
      purrr::walk(r_arguments, replace_argument, sparql_arguments = sparql_arguments)

      # COUNT(*)
      if (equivalent[["SPARQL"]] == "COUNT") {
        star <- xml2::xml_find_all(expr, ".//STR_CONST[contains(normalize-space(text()), '*')]")
        replace_star <- function(star) {
          xml2::xml_text(star) <- "*"
        }
        purrr::walk(star, replace_star)
      }

      # Remove ,
      commas = xml2::xml_find_all(expr, ".//OP-COMMA")
      xml2::xml_text(commas) = ";"

    } else {
      xml2::xml_attr(symbol_function_call, "sparqlish") = "false"
    }
  }

  xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL") %>%
    purrr::walk(treat_symbol_function_call)

  # then look for unique that is DISTINCT, not a function
  treat_unique = function(symbol_function_call) {
    expr = xml2::xml_parent(xml2::xml_parent(symbol_function_call))
    xml2::xml_text(symbol_function_call) = "DISTINCT "
    xml2::xml_attr(symbol_function_call, "sparqlish") = "true"
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-LEFT-PAREN"))
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-RIGHT-PAREN"))
  }

  code_data %>%
  xml2::xml_find_all(
    ".//SYMBOL_FUNCTION_CALL[normalize-space(text()) = 'unique']"
    ) %>%
  purrr::walk(treat_unique)

  # then add ?
  symbols = xml2::xml_find_all(code_data, ".//SYMBOL")
  xml2::xml_text(symbols) = add_question_mark(xml2::xml_text(symbols))

  # Abort if not sparqlish
  not_sparqlish = xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL[@sparqlish='false']")
  if (length(not_sparqlish) > 0) {
    rlang::abort(
      c(
      x = sprintf(
        "Can't find SPARQL equivalent for %s().",
        toString(
          purrr::map_chr(not_sparqlish, xml2::xml_text)
        )
      ),
        i = "If you think there should be one, open an issue in https://github.com/lvaudor/glitter."
      )
    )
  }

  # put it back together
  text = xml2::xml_text(code_data)
}
