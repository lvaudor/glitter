#' Add a triplet statement to a query
#' @param query query
#' @param triplet the triplet statement (replaces arguments subject verb and object)
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param required whether the existence of a value for the triplet is required or not (defaults to TRUE).
#'   If set to FALSE, then other triplets in the query are returned even if this particular triplet is missing)
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param within_box if provided, rectangular bounding box for the triplet query.
#'   Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query.
#'   Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers.
#'   The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param prefixes Custom prefixes
#' @export
#' @examples
#' # find the cities
#' spq_init() %>%
#' spq_add("?city wdt:P31/wdt:P279* wd:Q515", label = "?city") %>%
#' # and their populations
#' spq_add("?city wdt:P1082 ?pop", required = FALSE) %>%
#' # in a bounding box
#' spq_add("?city wdt:P625 ?coords", within_box = list(southwest = c(3,43), northeast = c(7,47))) %>%
#' # limit to 10 lines
#' spq_head(n = 10)
#'
#' \dontrun{
#' # find the individuals of the species
#' spq_init() %>%
#' spq_add("?mayor wdt:P31 ?species") %>%
#' # dog, cat or chicken
#' spq_add("?species %in% {c('wd:144','wd:146', 'wd:780')}") %>%
#' # who occupy the function
#' spq_add("?mayor p:P39 ?node") %>%
#' # of mayor
#' spq_add("?node ps:P39 wd:Q30185") %>%
#' # of some places
#' spq_add("?node pq:P642 ?place") %>%
#' spq_perform()
#' }
spq_add  =  function(query = NULL,
                      triplet = NULL,
                      subject = NULL,
                      verb = NULL,
                      object = NULL,
                      prefixes = NULL,
                      required = TRUE,
                      label = NA,
                      within_box = c(NA,NA),
                      within_distance = c(NA,NA)){
  elts = decompose_triplet(
    triplet = triplet,
    subject = subject,
    verb = verb,
    object = object
  )
  if (elts[1] == ".") {
    elts[1] = query$previous_subject
  }

  if (is.null(query)) {
    query = spq_init()
  }

  # previous subject
  query$previous_subject = elts[1]$subject

  # prefixed elements
  query$prefixes_used = c(
    query$prefixes_used,
    purrr::map_chr(unname(elts), keep_prefix)
  ) %>%
    stats::na.omit() %>%
    unique()
  # select
  query$select = build_part_select(
    query,
    elts$subject, elts$verb, elts$object,
    label
  )
  # body
  query$body = build_part_body(
    query,
    elts$subject, elts$verb, elts$object,
    required,
    within_box = within_box,
    within_distance = within_distance
  )

  return(query)
}
