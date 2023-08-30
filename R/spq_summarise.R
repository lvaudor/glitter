#' Summarise each group of results to fewer results
#' @inheritParams spq_arrange
#' @return A query object
#' @export
#' @examples
#' result = spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114") %>%
#' spq_label(area) %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(area, area_label)  %>%
#' spq_summarise(total_folkm = sum(folkm_ngd))
spq_summarise = function(.query, ...) {

  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)

  variable_names = names(variables)
  variable_names[!nzchar(variable_names)] <- variables[!nzchar(variable_names)]
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

  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )
  names(variables[!nzchar(names(variables))]) <- variables[!nzchar(names(variables))]
  # rest ----
  are_we_tallying = grepl("COUNT\\(\\*\\)", variables)

  no_grouping = (sum(.query[["structure"]][["grouping"]]) == 0)

  if (no_grouping && (!are_we_tallying)) {
    cli::cli_abort(
      c(
        "Can't summarize before grouping",
        i = "Use {.fun spq_group_by} first, or replace {.fun spq_summarize} with {.fun spq_mutate}"
      )
    )
  }

  # only keep grouping variables selected
  .query[["structure"]][["selected"]] = rep(FALSE, nrow(.query[["structure"]]))
  .query[["structure"]][["selected"]][.query[["structure"]][["grouping"]]] = TRUE

  for (var in variables) {

    formula_df = get_varformula(var)
    fun = sub("\\)$", "", sub("\\(.*", "", formula_df[["formula"]]))
    ancestor = formula_df[["args"]][[1]]
    name = sprintf("?%s", names(variables)[variables == var])

    .query = track_vars(
      .query = .query,
      name = name,
      formula = var,
      ancestor = ancestor,
      fun = fun
    )
    .query = spq_select(.query, spq(name))

  }

  return(.query)
}

#' @export
#' @rdname spq_summarise
spq_summarize <- spq_summarise
