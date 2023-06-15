#' Summarise each group of results to fewer results
#' @inheritParams spq_arrange
#' @return A query object
#' @export
#' @examples
#' result = spq_init() %>%
#' spq_add("?item wdt:P361 wd:Q297853") %>%
#' spq_add("?item wdt:P1082 ?folkm_ngd") %>%
#' spq_add("?area wdt:P31 wd:Q1907114", .label = "?area") %>%
#' spq_add("?area wdt:P527 ?item") %>%
#' spq_group_by(area, areaLabel)  %>%
#' spq_summarise(total_folkm = sum(folkm_ngd))
spq_summarise = function(.query, ...) {

  variables = purrr::map_chr(rlang::enquos(...), spq_treat_argument)


  variables[nzchar(names(variables))] = purrr::map2_chr(
    variables[nzchar(names(variables))],
    names(variables)[nzchar(names(variables))],
    add_as
  )

  names(variables[!nzchar(names(variables))]) <- variables[!nzchar(names(variables))]



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
