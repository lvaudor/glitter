#' Count the observations
#'
#' These functions are inspired by `dplyr::count()` and `dplyr::tally()`.
#' `spq_tally()` assumes you've already done the grouping.
#' @inheritParams spq_arrange
#' @param sort If `TRUE`, will show the largest groups at the top. (like the `sort` argument
#' of `dplyr::tally()`)
#' @param name Name for the count column (like the `name` argument
#' of `dplyr::tally()`)
#'
#' @return A query object
#' @export
#'
#' @examples
#' \dontrun{
#' spq_init() %>%
#' spq_add("?film wdt:P31 wd:Q11424") %>%
#' spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
#' spq_tally(name = "n_films") %>%
#' spq_perform()
#'
#' # the same with spq_count
#'
#' spq_init() %>%
#' spq_add("?film wdt:P31 wd:Q11424") %>%
#' spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
#' spq_count(name = "n_films") %>%
#' spq_perform()
#'
#' # Now with grouping
#' spq_init() %>%
#' spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
#' spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
#' spq_group_by(narrative_locationLabel) %>%
#' spq_tally(sort = TRUE, name = "n_films") %>%
#' spq_perform()
#'
#'
#' # More direct with spq_count()
#' spq_init() %>%
#' spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
#' spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
#' spq_count(narrative_locationLabel, sort = TRUE, name = "n_films") %>%
#' spq_perform()
#'}
#' @export
spq_tally = function(.query, sort = FALSE, name = "n") {
  full_formula = sprintf("(COUNT(*) AS ?%s)", name)

  .query[["select"]] = full_formula

   .query = track_vars(
    .query,
    name = name,
    formula = full_formula,
    fun = "COUNT",
    ancestor = "*",
    selected = TRUE,
    grouping = FALSE
  )

  if (!is.null(.query[["group_by"]])) {
    .query[["select"]] = union(.query[["select"]], .query[["group_by"]])

    if (sort) {
      .query <- spq_arrange(.query, spq(sprintf("DESC(?%s)", name)))
    }

  }

  .query
}

#' @rdname spq_tally
#' @inheritParams spq_group_by
#' @export
spq_count = function(.query, ..., sort = FALSE, name = "n") {

  if (length(rlang::enquos(...)) > 0) {
    .query <- spq_group_by(.query, ...)
  }

    spq_tally(.query, sort = sort, name = name)
}
