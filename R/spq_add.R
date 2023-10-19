#' Add a triple pattern statement to a query
#' @param .query query
#' @param .triple_pattern the triple pattern statement
#' (replaces arguments subject verb and object)
#' @param .subject an anonymous variable
#' (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param .verb the property (for instance "wdt:P190")
#' @param .object an anonymous variable (for instance,
#' and by default, "?object") or item (for instance "wd:Q456"))
#' @param .required whether the existence of a value for the triple is required
#' or not (defaults to TRUE).
#'   If set to FALSE, then other triples in the query are returned even
#'   if this particular triple is missing)
#' @param .label `r lifecycle::badge("deprecated")` See [`spq_label()`].
#' @param .within_box if provided, rectangular bounding box for the triple query.
#'   Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param .within_distance if provided, circular bounding box for the triple query.
#'   Provided as list(center=c(long=...,lat=...), radius=...),
#'   with radius in kilometers.
#'   The center can also be provided as a variable (for instance, "?location")
#'   for the center coordinates to be retrieved directly from the query.
#' @param .prefixes Custom prefixes
#' @param .filter Filter for the triple. Only use this with `.required=FALSE`
#' @param .sibling_triple_pattern Triple this triple is to be grouped with,
#' especially (only?) useful if the sibling triple is optional.
#' @export
#' @section Examples:
#' ```r
#' # find the cities
#' spq_init() %>%
#'   spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
#'   spq_label(city) %>%
#'   spq_mutate(coords = wdt::P625(city),
#'           .within_distance=list(center=c(long=4.84,lat=45.76),
#'                                radius=5)) %>%
#'   spq_perform()
#'
#' # find the individuals of the species
#' spq_init() %>%
#'   spq_add("?mayor wdt:P31 ?species") %>%
#'   # dog, cat or chicken
#'   spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
#'   # who occupy the function
#'   spq_add("?mayor p:P39 ?node") %>%
#'   # of mayor
#'   spq_add("?node ps:P39 wd:Q30185") %>%
#'   # of some places
#'   spq_add("?node pq:P642 ?place") %>%
#'   spq_perform()
#'
#' ```
#' @details
#' The arguments `.subject`, `.verb`, `.object` are most useful for programmatic
#' usage, they are actually used within glitter code itself.
spq_add = function(.query = NULL,
                    .triple_pattern = NULL,
                    .subject = NULL,
                    .verb = NULL,
                    .object = NULL,
                    .prefixes = NULL,
                    .required = TRUE,
                    .label = NA,
                    .within_box = c(NA, NA),
                    .within_distance = c(NA, NA),
                    .filter = NULL,
                    .sibling_triple_pattern = NA) {
  .query = .query %||% spq_init()

  elts = decompose_triple_pattern(
    triple_pattern = .triple_pattern,
    subject = .subject,
    verb = .verb,
    object = .object
  )
  if (elts[["subject"]] == ".") {
    elts[["subject"]] = .query[["previous_subject"]]
  }

  .query[["previous_subject"]] = elts[1][["subject"]]

  # standardized spacing :-)
  triple = paste(elts, collapse = " ")

  .query = track_triples(
    .query,
    triple = triple,
    required = .required,
    within_box = list(.within_box),
    within_distance = list(.within_distance),
    filter = .filter,
    sibling_triple = .sibling_triple_pattern
  )

  # variable tracking ----
  vars = purrr::keep(elts, \(x) !is.na(x) && startsWith(x, "?"))
  .query <- purrr::reduce(
    vars,
    add_one_var,
    triple = triple,
    .init = .query
  )

  # labelling ----
  if (!is.na(.label)) {
    lifecycle::deprecate_warn(
      when = "0.2.0",
      what = "spq_add(.label)",
      details = "Ability to use `.label` will be dropped in next release, use `spq_label()` instead."
    )
    .label <- gsub("^\\?", "", .label)
    .query <- spq_label(.query, !!!.label)
  }

  # prefixed elements ----
  .query[["prefixes_used"]] = union(
    .query[["prefixes_used"]],
    purrr::map(unname(elts), keep_prefix) %>%
      unlist() %>%
      purrr::discard(is.na)
  ) %>%
    stats::na.omit()

  .query
}

add_one_var <- function(.query, var, triple) {
  .query = track_vars(
    .query,
    name = var,
    triple = triple
  )
  .query = track_structure(
    .query,
    name = var,
    selected = TRUE
  )

  .query
}
