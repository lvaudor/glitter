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

  pieces <- build_pieces(.query = .query, endpoint = endpoint, strict = strict)

  paste0(
    pieces[["part_prefixes"]], "\n",
    "SELECT ", pieces[["spq_duplicate"]],
    paste0(pieces[["select"]], collapse = " "), "\n",
    "WHERE{\n",
    paste0(pieces[["body"]], collapse = ""), "\n", pieces[["binded"]],
    pieces[["filters"]], "\n",
    pieces[["service"]], "\n",
    "}\n",
    pieces[["group_by"]],
    pieces[["order_by"]], "\n",
    pieces[["limit"]],
    pieces[["offset"]]
  )
}

build_pieces <- function(.query, endpoint = "Wikidata", strict) {

  endpoint = .query[["endpoint"]] %||% endpoint


    if (endpoint != "Wikidata") {
    .query[["service"]] = ""
  }

  .query = spq_prefix(.query, auto = TRUE, prefixes = NULL)

  # prefixes -----
  prefixes_known = dplyr::bind_rows(.query[["prefixes_provided"]], usual_prefixes)
  purrr::walk(.query[["prefixes_used"]], check_prefix, prefixes_known = prefixes_known)

  part_prefixes <- if (nrow(.query[["prefixes_provided"]]) > 0) {
    glue::glue(
      'PREFIX {.query[["prefixes_provided"]][["name"]]}: <{.query[["prefixes_provided"]][["url"]]}>') %>%
      paste0(collapse = "\n")
  } else {
    ""
  }

  group_by <- if (sum(.query[["structure"]][["grouping"]]) > 0) {
    grouping_vars <- .query[["structure"]][["name"]][.query[["structure"]][["grouping"]]]
    paste0("GROUP BY ", paste0(grouping_vars, collapse = " "),"\n")
  } else {
    ""
  }

  if (is.null(.query[["service"]])) {
    .query = spq_language(.query, language = "en")
  }

  ordering <- .query[["structure"]][.query[["structure"]][["ordering"]] != "none",]

  order_by <- if (!is.null(ordering) && nrow(ordering) > 0) {
    ordering_vars = paste0(ordering[["ordering"]], collapse = " ")
    sprintf("ORDER BY %s", ordering_vars)
  }
  else {
    ""
  }

  # selections and bindings ----
  binded <- ""
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
        dplyr::pull(.data$selected_pattern)

      # hack to have formulas last
      # more readability if formulas use vars from select
      nongrouping_selected <- nongrouping_selected[order(grepl(" AS ", nongrouping_selected))]

      grouping_selected <- dplyr::filter(selected_df, grouping) %>%
        dplyr::group_by(name) %>%
        dplyr::summarize(selected_pattern = name[1]) %>%
        dplyr::pull(selected_pattern)

      if (length(grouping_selected) > 0) {
        to_bind <- dplyr::filter(.query[["vars"]],
          name %in% grouping_selected,
          !is.na(formula))
        if (nrow(to_bind) > 0) {
          binded <- paste(
            sprintf("BIND%s", to_bind[["formula"]]),
            collapse = "\n"
          )
          bind <- paste0(binded, "\n")
        }
      }

      # nicer to put grouping variables first
      c(grouping_selected, nongrouping_selected)
    }

  }

  # body ----
  triples_present = !is.null(.query[["triples"]])
  body = if (triples_present) {
    purrr::map_chr(
      split(.query[["triples"]], seq(nrow(.query[["triples"]]))),
      ~build_part_body(
        query = .query,
        triple = .x[["triple"]],
        required = .x[["required"]],
        within_box = .x[["within_box"]],
        within_distance = .x[["within_distance"]]
      ),
      .query = .query
    )
  } else {
    NULL
  }

 valued_vars <- .query[["vars"]][!is.na(.query[["vars"]][["values"]]),]

 if (!is.null(valued_vars) && nrow(valued_vars) > 0) {
    body <- c(
        body,
        sprintf("VALUES ?%s %s", valued_vars[["name"]], valued_vars[["values"]])
    )
  }

  # duplicate ----
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

  service = .query[["service"]]

  list(
    part_prefixes = part_prefixes,
    spq_duplicate = spq_duplicate,
    select = select,
    body = body,
    binded = binded,
    filters = filters,
    service = service,
    group_by = group_by,
    order_by = order_by,
    limit = limit,
    offset = offset
  )
}

utils::globalVariables(c("usual_prefixes", "formula", "selected_pattern"))
