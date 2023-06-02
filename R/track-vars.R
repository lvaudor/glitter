track_vars <- function(.query,
                       name,
                       triple = NA,
                       defining_triple = NA,
                       formula = NA,
                       fun = NA,
                       ancestor = NA,
                       selected,
                       spq_duplicate = NA,
                       grouping) {

  new_var <- tibble::tibble(
    name = name,
    triple = triple,
    defining_triple = defining_triple,
    formula = formula,
    fun = fun,
    ancestor = ancestor,
    selected = selected,
    spq_duplicate = spq_duplicate,
    grouping = grouping
  )
  .query[["vars"]] <- rbind(.query[["vars"]], new_var)

  .query
}
