#' Create the endpoint info object for `spq_init()`
#'
#' @param label_property Property used by the endpoint for labelling.
#'
#' @return A list to be used in `spq_init()`'s `endpoint_info` argument.
#' @export
#'
#' @examples
#' spq_endpoint_info(label_property = "skos:preflabel")
spq_endpoint_info <- function(label_property = "rdfs:prefLabel") {

  # TODO check property more
  if (!is.character(label_property)) {
    cli::cli_abort("Must provide a character as {.arg label_property}.")
  }

  structure(
    list(
      label_property = label_property
    ),
    class = "glitter_endpoint_info"
  )
}
