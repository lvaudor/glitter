spq_treat_argument = function(arg) {

  eval_try = try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  code <- if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    # e.g. `"desc(length)"`
    eval_try
  } else {
    # e.g. `desc(length)`, without quotes
    rlang::expr_text(arg) %>% str_remove("^~")
  }

  spq_translate_dsl(code)

}

spq_translate_dsl <- function(code) {
  code_data = parse_code(code)

  xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL") %>%
    purrr::walk(treat_symbol_function_call)

  # then look for unique that is DISTINCT, not a function
  code_data %>%
    xml2::xml_find_all(
      ".//SYMBOL_FUNCTION_CALL[normalize-space(text()) = 'unique']"
    ) %>%
    purrr::walk(treat_unique)

  # then look for n_distinct that also relates to DISTINCT
  code_data %>%
    xml2::xml_find_all(
      ".//SYMBOL_FUNCTION_CALL[normalize-space(text()) = 'n_distinct']"
    ) %>%
    purrr::walk(treat_ndistinct)
  # operators
  xml2::xml_find_all(code_data, ".//AND") %>% purrr::walk(replace_and)
  xml2::xml_find_all(code_data, ".//OR") %>% purrr::walk(replace_or)
  xml2::xml_find_all(code_data, ".//EQ") %>% purrr::walk(replace_eq)
  xml2::xml_find_all(code_data, ".//SPECIAL") %>% purrr::walk(replace_special)

  # then add ?
  in_a_colon <- function(node) {
    siblings <- node %>%
      xml2::xml_parent() %>%
      xml2::xml_siblings()
    any(xml2::xml_name(siblings) == "OP-COLON")
  }
  symbols = xml2::xml_find_all(code_data, ".//SYMBOL")
  symbols = purrr::discard(symbols, ~(!is.na(xml2::xml_attr(.x, "sparqlish")) && xml2::xml_attr(.x, "sparqlish") == "true"))
  variables = symbols[!(purrr::map_lgl(symbols, in_a_colon))]
  xml2::xml_text(variables) = add_question_mark(xml2::xml_text(variables))

  # Abort if not sparqlish
  not_sparqlish = xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL[@sparqlish='false']")
  if (length(not_sparqlish) > 0) {
    cli::cli_abort(
      c(
        x = sprintf(
          "Can't find SPARQL equivalent for %s().",
          toString(
            purrr::map_chr(not_sparqlish, xml2::xml_text)
          )
        ),
        i = "If you think there should be one, open an issue in https://github.com/lvaudor/glitter."
      ),
      call = NULL
    )
  }

  # put it back together
  text <- xml2::xml_text(code_data)

  if (text == "COUNT()") {
    text <- "COUNT(*)"
  }

  text

}

add_question_mark = function(x) sprintf("?%s", x)

# If running into issues look into the safe parsing downlit has
parse_code = function(code) {
  parse(
    text = code,
    keep.source = TRUE
  ) %>%
    xmlparsedata::xml_parse_data(pretty = TRUE) %>%
    xml2::read_xml()
}

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
    if (!(equivalent[["SPARQL"]] %in% c("REGEX", "", "COALESCE", "SUBSTR"))) {
      commas = xml2::xml_find_all(expr, ".//OP-COMMA")
      xml2::xml_text(commas) = ";"
    }

  } else {
    xml2::xml_attr(symbol_function_call, "sparqlish") = "false"
  }
}

treat_unique = function(symbol_function_call) {
  expr = xml2::xml_parent(xml2::xml_parent(symbol_function_call))
  xml2::xml_text(symbol_function_call) = "DISTINCT "
  xml2::xml_attr(symbol_function_call, "sparqlish") = "true"
  xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-LEFT-PAREN"))
  xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-RIGHT-PAREN"))
}

treat_ndistinct = function(symbol_function_call) {
  expr = xml2::xml_parent(xml2::xml_parent(symbol_function_call))
  xml2::xml_text(symbol_function_call) = "COUNT"
  xml2::xml_attr(symbol_function_call, "sparqlish") = "true"

  arg <- xml2::xml_find_first(expr, ".//SYMBOL")
  xml2::xml_text(arg) <- sprintf(
    "DISTINCT ?%s",
    xml2::xml_text(arg)
  )
  xml2::xml_attr(arg, "sparqlish") = "true"
}

replace_and = function(and) {
  xml2::xml_text(and) <- "&&"
}

replace_or = function(or) {
  xml2::xml_text(or) <- "||"
}

replace_eq = function(eq) {
  xml2::xml_text(eq) <- "="
}

replace_special <- function(special) {
  text <- xml2::xml_text(special)

  if (text == "%in%") {
    xml2::xml_text(special) <- " IN "
  }
}
