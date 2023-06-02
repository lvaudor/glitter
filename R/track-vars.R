track_vars <- function(.query,
                       name,
                       triple = NA,
                       defining_triple = NA,
                       values = NA,
                       formula = NA,
                       fun = NA,
                       ancestor = NA,
                       selected,
                       grouping) {

  new_var <- tibble::tibble(
    name = name,
    triple = triple,
    defining_triple = defining_triple,
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
