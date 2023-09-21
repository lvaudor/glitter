#' Assemble query parts into a proper SPARQL query
#' @param .query a list with elements of the query
#' @param strict whether to perform some linting on the query,
#' and error in case a problem is detected.
#' @return A query object
#' @export
#' @examples
#' spq_init() %>%
#'   spq_add("?city wdt:P31 wd:Q515") %>%
#'   spq_label(city, .languages = "fr$") %>%
#'   spq_add("?city wdt:P1082 ?pop") %>%
#'   spq_assemble() %>%
#'   cat()
spq_assemble = function(.query, strict = TRUE) {

  endpoint = .query[["endpoint"]]

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

      nongrouping_selected_df = dplyr::filter(selected_df, !grouping) %>%
        dplyr::group_by(name) %>%
        # TODO it'd probably be weird to have >1 formula
        # so check that
        dplyr::summarize(selected_pattern = dplyr::if_else(
          any(!is.na(formula)),
          formula[!is.na(formula)][1],
          name[1]
        ))
        nongrouping_selected = nongrouping_selected_df[["selected_pattern"]]
        nongrouping_selected = rlang::set_names(
          nongrouping_selected,
          nongrouping_selected_df[["name"]]
        )

      # hack to have formulas last
      # more readability if formulas use vars from select
      nongrouping_selected <- nongrouping_selected[order(grepl(" AS ", nongrouping_selected))]

      grouping_selected <- dplyr::filter(selected_df, grouping) %>%
        dplyr::group_by(name) %>%
        dplyr::summarize(selected_pattern = name[1]) %>%
        dplyr::pull(selected_pattern)

      # we get this to be sure to include any ancestor
      # of selected var in a BIND
      selected_vars = .query[["vars"]][.query[["vars"]][["name"]] %in% selected_df[["name"]],]
      ancestor_vars = selected_vars[!is.na(selected_vars[["ancestor"]]),]

      filtered_vars = selected_vars[selected_vars[["name"]] %in% .query[["filters"]][["var"]],]

      potential_binded <- c(grouping_selected, ancestor_vars[["ancestor"]], filtered_vars[["name"]])
      if (length(potential_binded) > 0) {
        to_bind <- dplyr::filter(.query[["vars"]],
          name %in% potential_binded,
          !is.na(formula))
        if (nrow(to_bind) > 0) {
          binded <- paste(
            sprintf("BIND%s", to_bind[["formula"]]),
            collapse = "\n"
          )
          bind <- paste0(binded, "\n")
        }
      } else {
        to_bind = NULL
      }

      # nicer to put grouping variables first
      select = c(grouping_selected, nongrouping_selected)

      # put labels near variables
      any_label = any(grepl("_label", select))
      if (any_label) {
        new_select = select[!grepl("_label", select)]
        labels = select[grepl("_label", select)]
        select = purrr::reduce2(
          labels,
          names(labels),
          \(new_select, x, y) add_label(new_select, x, y, old_select = select),
          .init = new_select
        )
      }

      # do not use formula both in BIND and SELECT
      # so remove it from SELECT
      select[names(select) %in% to_bind[["name"]]] =
        names(select)[names(select) %in% to_bind[["name"]]]
      select
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
        within_distance = .x[["within_distance"]],
        filter = .x[["filter"]]
      ),
      .query = .query
    ) |>
      paste0(collapse = "")
  } else {
    NULL
  }

 valued_vars <- .query[["vars"]][!is.na(.query[["vars"]][["values"]]),]

 if (!is.null(valued_vars) && nrow(valued_vars) > 0) {
    body <- paste(
      c(
        body,
        sprintf("VALUES ?%s %s", valued_vars[["name"]], valued_vars[["values"]])
        ),
      collapse = "\n"
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

  paste0(
    part_prefixes, "\n",
    "SELECT ", spq_duplicate, paste0(select,collapse = " "), "\n",
    "WHERE {\n",
    body, "\n", binded,
    filters, "\n",
    "}\n",
    group_by,
    order_by, "\n",
    limit,
    offset
  )
}

utils::globalVariables(c("usual_prefixes", "formula", "selected_pattern"))

add_label = function(vector, label, label_name, old_select) {
  unlabelled = which(sprintf("%s_label", vector) == label_name)
  unlabelled_present = (length(unlabelled) == 1)

  if (unlabelled_present) {
   return(append(vector, label, after = unlabelled))
  }

   old_position = which(old_select == label)
   if (old_position == 1) {
     return(append(vector, label, after = 0))
   }

   old_neighbour = old_select[old_position - 1]
   old_neighbour_current_position = which(vector == old_neighbour)
   append(vector, label, after = old_neighbour_current_position)

}
