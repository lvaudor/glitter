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

  pieces = .query %>%
    build_pieces(endpoint = endpoint, strict = strict) %>%
    format_pieces()

  paste0(
    pieces[["part_prefixes"]], "\n",
    pieces[["part_select"]], "\n",
    pieces[["part_body"]],
    pieces[["part_group_by"]],
    pieces[["part_order_by"]], "\n",
    pieces[["part_limit"]],
    pieces[["part_offset"]]
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

  group_by = if (sum(.query[["structure"]][["grouping"]]) > 0) {
    .query[["structure"]][["name"]][.query[["structure"]][["grouping"]]]
  } else {
    NULL
  }

  if (is.null(.query[["service"]])) {
    .query = spq_language(.query, language = "en")
  }

  ordering <- .query[["structure"]][.query[["structure"]][["ordering"]] != "none",]

  order_by <- if (!is.null(ordering) && nrow(ordering) > 0) {
    ordering[["ordering"]]
  }
  else {
    NULL
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
        paste(
          purrr::map2_chr(valued_vars[["name"]], valued_vars[["values"]], ~sprintf("VALUES ?%s %s", .x, .y)),
          collapse = "\n"
        )
    )
  }

  # duplicate ----
  spq_duplicate <- if (is.null(.query[["spq_duplicate"]])) {
    ""
  } else {
    sprintf("%s ", .query[["spq_duplicate"]])
  }

  limit = .query[["limit"]]

  offset = .query[["offset"]]

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
    prefixes_provided = .query[["prefixes_provided"]],
    spq_duplicate = spq_duplicate,
    select = select,
    body = body,
    binded = binded,
    filters = filters,
    raw_filters = .query[["filters"]][["filter"]],
    service = service,
    group_by = group_by,
    order_by = order_by,
    limit = limit,
    offset = offset
  )
}

format_pieces <- function(pieces) {
  part_prefixes <- if (nrow(pieces[["prefixes_provided"]]) > 0) {
    glue::glue(
      'PREFIX {pieces[["prefixes_provided"]][["name"]]}: <{pieces[["prefixes_provided"]][["url"]]}>') %>%
      paste0(collapse = "\n")
  } else {
    ""
  }

  part_select = paste(
    "SELECT",
    pieces[["spq_duplicate"]],
    paste0(pieces[["select"]], collapse = " ")
  ) %>%
    stringr::str_squish()

  part_body = paste0(
    "WHERE{\n",
    paste0(pieces[["body"]], collapse = ""), "\n", pieces[["binded"]],
    pieces[["filters"]], "\n",
    pieces[["service"]], "\n",
    "}\n"
  )

  part_order_by = if (!is.null(pieces[["order_by"]])) {
    ordering_vars = paste0(pieces[["order_by"]], collapse = " ")
    sprintf("ORDER BY %s", ordering_vars)
  }
  else {
    ""
  }


  part_group_by = if (length(pieces[["group_by"]]) > 0) {
    paste0("GROUP BY ", paste0(pieces[["group_by"]], collapse = " "),"\n")
  } else {
    ""
  }

  part_limit = if (is.null(pieces[["limit"]])) {
    ""
  } else {
    glue::glue('LIMIT {pieces[["limit"]]}\n')
  }

  part_offset = if (is.null(pieces[["offset"]])) {
    ""
  } else {
    glue::glue('OFFSET {pieces[["offset"]]}\n')
  }
  list(
    part_prefixes = part_prefixes,
    part_select = part_select,
    part_body = part_body,
    part_group_by = part_group_by,
    part_order_by = part_order_by,
    part_limit = part_limit,
    part_offset = part_offset
  )
}

utils::globalVariables(c("usual_prefixes", "formula", "selected_pattern"))
