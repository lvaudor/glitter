#' Create and modify variables in the results
#' @inheritParams spq_arrange
#' @inheritParams spq_add
#' @export
#' @section Some examples:
#'
#' ```r
#' # common name of a plant species in different languages
#' # the triplet pattern "wd:Q331676 wdt:P1843 ?statement" creates the variable statement
#' # hence our writing it in reverse within the spq_mutate() function
#' spq_init() %>%
#' spq_mutate(statement = wdt::P1843(wd::Q331676)) %>%
#' spq_mutate(lang = lang(statement))
#' ```
spq_mutate = function(.query, ..., .label = NA, .within_box = c(NA, NA), .within_distance = c(NA, NA)){
  variables =  purrr::map(rlang::enquos(...), spq_treat_mutate_argument)
  variable_names <- names(variables)

  # Normal variables :-)
  normal_variables <- variables[purrr::map_lgl(variables, is.character)]
  normal_variables[nzchar(names(normal_variables))] = purrr::map2_chr(
    normal_variables[nzchar(names(normal_variables))],
    names(normal_variables)[nzchar(names(normal_variables))],
    add_as
  )

  .query$select <- unique(c(.query$select, normal_variables))

  # Triplet variables
  triple_variables <- variables[purrr::map_lgl(variables, is.list)]
  triple_variable_names <- names(triple_variables)
  for (i in seq_along(triple_variables)) {
    .query = spq_add(
      .query,
      .subject = triple_variables[[i]][["subject"]],
      .verb = triple_variables[[i]][["verb"]],
      .object = sprintf("?%s", triple_variable_names[[i]]),
      .label = .label,
      .within_distance = .within_distance,
      .within_box = .within_box
    )
  }


  return(.query)
}

spq_treat_mutate_argument = function(arg, arg_name) {

  eval_try = try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  code <- if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    # e.g. `"desc(length)"`
    eval_try
  } else {
    # e.g. `desc(length)`, without quotes
    rlang::expr_text(arg) %>% stringr::str_replace("^~", "")
  }

  if (!grepl("::", code)) {
    spq_translate_dsl(code)
  } else {
    spq_parse_verb_object(code, reverse = TRUE)
  }

}
