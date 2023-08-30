spq_treat_triple_pattern <- function(triple_pattern) {

  eval_try = try(rlang::eval_tidy(triple_pattern), silent = TRUE)

  if (is.spq(eval_try)) {
    elts = decompose_triple_pattern(
      triple_pattern = triple_pattern,
      subject = NULL,
      verb = NULL,
      object = NULL
    )
    return(eval_try)
  }

  code <- if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    # e.g. `"desc(length)"`
    eval_try
  } else {
    # e.g. `desc(length)`, without quotes
    rlang::expr_text(triple_pattern) %>% str_remove("^~")
  }

  spq_parse_verb_object(code)
}

spq_parse_verb_object <- function(code, reverse = FALSE) {

  code_data = parse_code(code)
  predicates <- xml2::xml_find_all(code_data, ".//SYMBOL_FUNCTION_CALL") %>%
    purrr::map_chr(treat_p_o) %>%
    paste0(collapse = "/")

  object <-  xml2::xml_find_all(code_data, ".//SYMBOL") %>%
    purrr::map_chr(treat_p_o) %>%
    unique()

  if (length(object) > 1) {
    rlang::abort("Can't use more than one object per triple")
  }

  if (!reverse) {
    elements <- list(
      verb = predicates,
      object = object
    )
  } else {
    # the spq_mutate syntax reversed the triple pattern order
    elements <- list(
      verb = predicates,
      subject = object
    )
  }

  return(elements)
}

treat_p_o <- function(predicate) {
  property <- predicate %>% xml2::xml_text()

  prefix <- xml2::xml_siblings(predicate)[1] %>% xml2::xml_text()

  # TODO: not good to use this if several predicates e.g. not ok to have ?instance_of/wdt:P279*
  if (length(prefix) == 0) {
    return(sprintf("?%s", property))
  }

  if (grepl("_all$", property)) {
    property <- sub("_all$", "*", property)
  }
  sprintf("%s:%s", prefix, property)
}
