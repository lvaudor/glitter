#' Create and modify variables in the results
#' @inheritParams spq_arrange
#' @inheritParams spq_add
#' @return A query object
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
spq_mutate = function(.query, ..., .label = NA, .within_box = c(NA, NA), .within_distance = c(NA, NA)) {
  variables = purrr::map(rlang::enquos(...), spq_treat_mutate_argument)
  variable_names = names(variables)

  # when trying to overwrite a variable name ----
  renaming_to_do = any(question_mark(variable_names) %in% .query[["vars"]][["name"]])
  if (renaming_to_do) {
    ## rename in existing query object ----
    to_rename = un_question_mark(
      intersect(question_mark(variable_names), .query[["vars"]][["name"]])
    )
    .query = purrr::reduce(
      to_rename,
      \(.query, x) spq_rename_var(.query, old = x, new = sprintf("%s0", x)),
      .init = .query
    )
    ## rename in current arguments ----
    rename_in_defs = function(x, variables) {
      gsub(question_mark_escape(x), question_mark(sprintf("%s0", x)), variables)
    }
    variables = purrr::reduce(
      to_rename,
      \(variables, x) rename_in_defs(x, variables),
      .init = variables
    )
    variables = rlang::set_names(variables, variable_names)
    ## unselect the overwritten variable ----
    .query <- spq_select(.query, !!!sprintf("-%s0", to_rename))
  }

  # Non-triple variables :-)
  normal_variables = variables[purrr::map_lgl(variables, is.character)]
  normal_variables[nzchar(names(normal_variables))] = purrr::map2_chr(
    normal_variables[nzchar(names(normal_variables))],
    names(normal_variables)[nzchar(names(normal_variables))],
    add_as
  )
  for (var in normal_variables) {
    name = sprintf("?%s", names(normal_variables)[normal_variables == var])

    formula_df = get_varformula(var)
    .query = track_vars(
      .query = .query,
      name = name,
      formula = var,
      ancestor = formula_df[["args"]][[1]],
      fun = sub("\\)$", "", sub("\\(.*", "", formula_df[["formula"]]))
    )

    .query = track_structure(.query, name = name, selected = TRUE)

  }

  # 'Triple' variables
  triple_variables = variables[purrr::map_lgl(variables, is.list)]
  triple_variable_names = names(triple_variables)
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

  # labelling ----
  if (!is.na(.label)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "spq_add(.label)",
      details = "Ability to use `.label` will be dropped in next release, use `spq_label()` instead."
    )
    .label = gsub("^\\?", "", .label)
    .query = spq_label(.query, !!!.label)
  }

  return(.query)
}

spq_treat_mutate_argument = function(arg, arg_name) {
  eval_try = try(rlang::eval_tidy(arg), silent = TRUE)

  if (is.spq(eval_try)) {
    return(eval_try)
  }

  code = if (!inherits(eval_try, "try-error") && is.character(eval_try)) {
    # e.g. `"desc(length)"`
    eval_try
  } else {
    # e.g. `desc(length)`, without quotes
    rlang::expr_text(arg) %>% str_remove("^~")
  }

  if (!grepl("::", code)) {
    spq_translate_dsl(code)
  } else {
    spq_parse_verb_object(code, reverse = TRUE)
  }
}
