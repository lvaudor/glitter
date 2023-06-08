track_vars <- function(.query,
                       name,
                       triple = NA,
                       values = NA,
                       formula = NA,
                       fun = NA,
                       ancestor = NA,
                       selected,
                       grouping) {

  new_var <- tibble::tibble(
    name = name,
    triple = triple,
    values = values,
    formula = formula,
    fun = fun,
    ancestor = ancestor,
    selected = selected,
    grouping = grouping
  )
  .query[["vars"]] <- rbind(.query[["vars"]], new_var)

  .query
}

track_triples <- function(.query,
                          triple,
                          required,
                          within_box,
                          within_distance) {
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

  new_triple <- tibble::tibble(
    triple = triple,
    required = required,
    within_box = within_box,
    within_distance = within_distance
  )

  .query[["triples"]] <- rbind(.query[["triples"]], new_triple)

  .query
}
