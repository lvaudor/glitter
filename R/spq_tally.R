#' Count the observations
#'
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
#' spq_init() %>%
#' spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
#' spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
#' spq_group_by(narrative_locationLabel) %>%
#' spq_tally(sort = TRUE, name = "n_films") %>%
#' spq_perform()
#'}
#' @export
spq_tally = function(.query, sort = FALSE, name = "n") {
  .query[["select"]] <- sprintf("(COUNT(*) AS ?%s)", name)

  if (!is.null(.query[["group_by"]])) {
    .query[["select"]] <- c(.query[["select"]], .query[["group_by"]])

    if (sort) {
      .query <- spq_arrange(.query, spq(sprintf("DESC(?%s)", name)))
    }

  }

  .query
}
