track_structure <- function(.query,
                            name,
                            selected = NULL,
                            grouping = NULL,
                            ordering = NULL
                          ) {

  if (name %in% .query[["structure"]][["name"]]) {
    if (!is.null(selected)) {
      .query[["structure"]][["selected"]][.query[["structure"]][["name"]] == name] <- selected
    }
    if (!is.null(grouping)) {
      .query[["structure"]][["grouping"]][.query[["structure"]][["name"]] == name] <- grouping
    }
    if (!is.null(ordering)) {
      .query[["structure"]][["ordering"]][.query[["structure"]][["name"]] == name] <- ordering
    }
    return(.query)
  }

  selected = selected %||% TRUE
  grouping = grouping %||% FALSE
  ordering = ordering %||% "none"

  .query[["structure"]] <- rbind(
    .query[["structure"]],
    tibble::tibble(
      name = name,
      selected = selected,
      grouping = grouping,
      ordering = ordering
    )
  )

  .query
}

track_vars <- function(.query,
  name,
  triple = NA,
  values = NA,
  formula = NA,
  fun = NA,
  ancestor = NA) {

  new_var <- tibble::tibble(
    name = name,
    triple = triple,
    values = values,
    formula = formula,
    fun = fun,
    ancestor = ancestor,
    renamed = FALSE
  )
  .query[["vars"]] <- rbind(.query[["vars"]], new_var)

  .query
}

track_triples <- function(.query,
                          triple,
                          required,
                          within_box,
                          within_distance,
                          filter = NULL) {
  if (triple %in% .query[["triples"]][["triple"]]) {
    cli::cli_abort("Duplicate triple {.val triple}")
  }

  no_within_box = (sum(is.na(within_box[[1]])) == 2)
  if (no_within_box) {
    within_box = NA
  }

  no_within_distance = (sum(is.na(within_distance[[1]])) == 2)
  if (no_within_distance) {
    within_distance = NA
  }

  filter = filter %||% NA

  new_triple <- tibble::tibble(
    triple = triple,
    required = required,
    within_box = within_box,
    within_distance = within_distance,
    filter = filter
  )

  .query[["triples"]] <- rbind(.query[["triples"]], new_triple)

  .query
}

track_filters <- function(.query, filter) {
  var <- str_extract(filter, "\\(\\?(.*?)\\)")
  var <- sub("\\,.*", "", sub("\\(", "", sub("\\)", "", var)))
  new_filter <- tibble::tibble(filter = filter, var = var)

  .query[["filters"]] <- rbind(.query[["filters"]], new_filter)

  .query
}
