spq_rename_var <- function(.query, old, new) {
  # error if the old variable name is not in vars
  if (!(question_mark(old) %in% .query[["vars"]][["name"]])) {
    cli::cli_abort("Can't rename {.field {old}} as it's not present in the query object.")
  }

  # error if the new variable name is in vars
  if (question_mark(new) %in% .query[["vars"]][["name"]]) {
    cli::cli_abort("Can't rename {.field {old}} to {.field {new}} as {.field {new}} already exists.")
  }

  .query[["vars"]] <- spq_rename_var_in_df(.query[["vars"]], old, new)

  .query[["structure"]] <- spq_rename_var_in_df(.query[["structure"]], old, new)

  .query[["triples"]] <- spq_rename_var_in_df(.query[["triples"]], old, new)

  if (!is.null(.query[["filters"]])) {
    .query[["filters"]] <- spq_rename_var_in_df(.query[["filters"]], old, new)
  }

  .query
}

spq_rename_var_in_df <- function(df, old, new) {
  columns_to_transform <- names(df)[unlist(lapply(df, class)) == "character"]
   dplyr::mutate(
    df,
    dplyr::across(
    tidyselect::all_of(columns_to_transform),
    \(x) sub(question_mark_escape(old), question_mark(new), x)
  ))
}
