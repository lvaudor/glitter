spq_rename_var <- function(.query, old, new) {

  if (!(question_mark(old) %in% .query[["vars"]][["name"]])) {
    cli::cli_abort("Can't rename {.field {old}} as it's not present in the query object.")
  }

  if (question_mark(new) %in% .query[["vars"]][["name"]]) {
    if (any(.query[["vars"]][["renamed"]][.query[["vars"]][["name"]] == question_mark(new)])) {
      .query = spq_rename_var(.query, new, sprintf("%s0", new))
    } else {
      cli::cli_abort("Can't rename {.field {old}} to {.field {new}} as {.field {new}} already exists.")
    }

  }

  .query[["vars"]] <- spq_rename_var_in_df(.query[["vars"]], old, new)
  .query[["vars"]][["renamed"]][.query[["vars"]][["name"]] == question_mark(new)] <- TRUE

  .query[["structure"]] <- spq_rename_var_in_df(.query[["structure"]], old, new)

  .query[["triples"]] <- spq_rename_var_in_df(.query[["triples"]], old, new)

  if (!is.null(.query[["filters"]])) {
    .query[["filters"]] <- spq_rename_var_in_df(.query[["filters"]], old, new)
  }

  .query
}

spq_rename_var_in_df <- function(df, old, new) {
  columns_to_transform = names(df)[unlist(lapply(df, class)) == "character"]
  replaced = question_mark_escape(old)
  replacer = question_mark(new)

  purrr::reduce(
    columns_to_transform,
    \(df, x) rename_col(df, x, replaced, replacer),
    .init = df
  )
}

rename_col <- function(df, x, replaced, replacer) {
  df[[x]] = sub(replaced, replacer, df[[x]])
  return(df)
}
