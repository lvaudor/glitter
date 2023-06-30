#' Assemble query parts into a proper SPARQL query
#' @param .query a list with elements of the query
#' @param endpoint SPARQL endpoint to send the query to
#' @param strict whether to perform some linting on the query,
#' and error in case a problem is detected.
#' @return A query object
#' @export
#' @examples
#' spq_init() %>%
#'   spq_add("?city wdt:P31 wd:Q515", .label="?city") %>%
#'   spq_add("?city wdt:P1082 ?pop") %>%
#'   spq_language("fr") %>%
#'   spq_assemble() %>%
#'   cat()
spq_assemble = function(.query,
                        endpoint = "Wikidata",
                        strict = TRUE) {

  if (endpoint != "Wikidata") {
    .query$service = ""
  }

  .query = spq_prefix(.query, auto = TRUE, prefixes = NULL)

  # prefixes -----
  prefixes_known = dplyr::bind_rows(.query$prefixes_provided, usual_prefixes)
  purrr::walk(.query$prefixes_used, check_prefix, prefixes_known = prefixes_known)

  part_prefixes <- if (nrow(.query[["prefixes_provided"]]) > 0) {
    glue::glue(
      "PREFIX {.query$prefixes_provided$name}: <{.query$prefixes_provided$url}>") %>%
      paste0(collapse = "\n")
  } else {
    ""
  }

  group_by <- if (!is.null(.query[["group_by"]])) {
    paste0("GROUP BY ", paste0(.query[["group_by"]], collapse = " "),"\n")
  } else {
    ""
  }

  if (is.null(.query[["service"]])) {
    .query = spq_language(.query, language = "en")
  }

  order_by <- if (length(.query[["order_by"]]) > 0) {
    sprintf("ORDER BY %s", paste(.query[["order_by"]], collapse = " "))
  }
  else {
    ""
  }

  select <- if (sum(.query[["structure"]][["selected"]]) == 0) {
    "*"
  } else {
    selected <- .query[["structure"]][["name"]][.query[["structure"]][["selected"]]]

    # no var defined: this happens in testing
    # and other contexts where we demo functions partially
    select <- if (is.null(.query[["vars"]])) {
      selected
    } else {
      selected_df <- .query[["vars"]] %>%
        dplyr::filter(name %in% selected) %>%
        dplyr::select(name, formula) %>%
        dplyr::distinct() %>%
        dplyr::left_join(.query[["structure"]], by = "name")

      nongrouping_selected <- dplyr::filter(selected_df, !grouping) %>%
        dplyr::group_by(name) %>%
        # TODO it'd probably be weird to have >1 formula
        # so check that
        dplyr::summarize(selected_pattern = dplyr::if_else(
          any(!is.na(formula)),
          formula[!is.na(formula)][1],
          name[1]
        )) %>%
        dplyr::pull(selected_pattern)

      # hack to have formulas last
      # more readability if formulas use vars from select
      nongrouping_selected <- nongrouping_selected[order(grepl(" AS ", nongrouping_selected))]

      grouping_selected <- dplyr::filter(selected_df, grouping) %>%
        dplyr::group_by(name) %>%
        dplyr::summarize(selected_pattern = name[1]) %>%
        dplyr::pull(selected_pattern)

      if (length(grouping_selected) > 0) {
        browser()
      to_bind <- .query[["vars"]][.query[["vars"]]["name"] %in% grouping_selected]
      }

      c(nongrouping_selected, grouping_selected)
    }

  }

  spq_duplicate <- if (is.null(.query[["spq_duplicate"]])) {
    ""
  } else {
    sprintf("%s ", .query[["spq_duplicate"]])
  }

  limit <- if (is.null(.query[["limit"]])) {
    ""
  } else {
    glue::glue('LIMIT {.query[["limit"]]}\n')
  }

  offset <- if (is.null(.query[["offset"]])) {
    ""
  } else {
    glue::glue('OFFSET {.query[["offset"]]}')
  }

  filters <- if (is.null(.query[["filters"]])) {
    ""
  } else {
    if (strict) {

      unknown_filtered_variables <- .query[["filters"]][["var"]][
        !(.query[["filters"]][["var"]] %in% .query[["vars"]][["name"]])
      ]
      if (length(unknown_filtered_variables) > 0) {
        cli::cli_abort(
          c(
            "Can't filter on undefined variables: {toString(unknown_filtered_variables)}",
            i = "You haven't mentioned them in any triple, VALUES, mutate."
          )
        )
      }
    }

    paste0(
      sprintf("FILTER(%s)", .query[["filters"]][["filter"]]),
      collapse = "\n"
    )
  }

  paste0(
    part_prefixes, "\n",
    "SELECT ", spq_duplicate, paste0(select,collapse = " "), "\n",
    "WHERE{\n",
    .query[["body"]], "\n",
    filters, "\n",
    .query[["service"]], "\n",
    "}\n",
    group_by,
    order_by, "\n",
    limit,
    offset
  )
}

utils::globalVariables("usual_prefixes")
