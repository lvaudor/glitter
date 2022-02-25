#' Select particular variables
#' @inheritParams spq_arrange
#' @export
#' @examples
#'
spq_select = function(query = NULL, ...){
  selected_variables <- purrr::map_chr(
    rlang::enquos(...),
    treat_select_argument
  )

  # add name for AS bla

  prev_vars=query$select

  # positively identified variables
  plus_variables=variables %>%
    stringr::str_subset("^\\?")
  # negatively identified variables
  minus_variables=variables %>%
    stringr::str_subset("^\\-\\?") %>%
    stringr::str_remove("\\-")

  # If some variables are positively identified,
  # keep only these, else keep all
  if(length(plus_variables>0)){
    new_vars=prev_vars %>%
      subset(prev_vars %in% plus_variables)
  }else{
    new_vars=prev_vars
  }
  # If some variables are negatively identified,
  # keep all but these, else keep all
  if(length(minus_variables>0)){
    new_vars=new_vars %>%
      subset(!(new_vars %in% minus_variables))
  }
  query$select=unique(new_vars)
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
    equivalent <- all_correspondences[["SPARQL"]][all_correspondences[["R"]] == xml2::xml_text(symbol_function_call)]
    if (length(equivalent) > 0) {
      xml2::xml_text(symbol_function_call) <- equivalent
      xml2::xml_attr(symbol_function_call, "sparqlish") <- "true"
    } else {
      xml2::xml_attr(symbol_function_call, "sparqlish") <- "false"
    }
  }
  symbol_function_calls <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL")

  purrr::walk(symbol_function_calls, treat_symbol_function_call)

  # then look for unique
  treat_unique <- function(symbol_function_call) {
    browser()
    expr <- xml2::xml_parent(xml2::xml_parent(symbol_function_call))
    xml2::xml_text(symbol_function_call) <- "DISTINCT "
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-LEFT-PAREN"))
    xml2::xml_remove(xml2::xml_find_all(expr, ".//OP-RIGHT-PAREN"))
  }
  unique_calls <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL[normalize-space(text()) = 'unique']")

  purrr::walk(unique_calls, treat_unique)


  # then add ?
  symbols <- xml2::xml_find_all(code_data, ".//SYMBOL")
  xml2::xml_text(symbols) <- add_question_mark(xml2::xml_text(symbols))



  # put it back together
  paste(code_data$text, collapse = "")

}
