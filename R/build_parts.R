#' Builds the "body" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param required whether the existence of a value for the triple is required or not (defaults to TRUE).
#'   If set to FALSE, then other triples in the query are returned even if this particular triple is missing)
#' @param within_box if provided, north-west and south-east coordinates of bounding box for the triple query.
#' @param within_distance if provided, north-west and south-east coordinates of bounding box for the triple query.
#' @noRd
build_part_body = function(query = NA,
                           triple = NULL,
                           subject = NULL,
                           verb = NULL,
                           object = NULL,
                           required = TRUE,
                           within_box = c(NA, NA),
                           within_distance = c(NA, NA),
                           filter = NA) {

  part_body = query[["body"]]

  if (!is.na(triple)) {
    elts = decompose_triple_pattern(triple)
    subject = elts[["subject"]]
    verb = elts[["verb"]]
    object = elts[["object"]]
  }

  triple_is_not_regular_rdf <- verb %in% c("is","==","%in%")
  if (triple_is_not_regular_rdf) {
    values = paste(as_values(object), collapse = "\n")
    new_triple = glue::glue(
      "VALUES {{subject}}{\n{{values}}\n}",
      .open = "{{", .close = "}}"
      )
  } else {
    new_triple = glue::glue("{subject} {verb} {object}.")
  }

  if (!required) {
    new_triple = if (!is.null(filter)) {
      sprintf("OPTIONAL {\n\t%s\n\tFILTER(%s)\n}\n", new_triple, filter)
    } else {
      sprintf("OPTIONAL {%s}", new_triple)
    }
  }

  # when arg within_box is provided use service wikibase:box
  if (!is.na(within_box[[1]][1])) {
    new_triple = paste0(
      "SERVICE wikibase:box {\n",
      new_triple,"\n",
      "bd:serviceParam wikibase:cornerSouthWest 'Point(",
      within_box$southwest[1]," ", within_box$southwest[2],
      ")'^^geo:wktLiteral.\n",
      "bd:serviceParam wikibase:cornerNorthEast 'Point(",
      within_box$northeast[1]," ", within_box$northeast[2],
      ")'^^geo:wktLiteral.\n}"
    )
  }
  # when arg within_distance is provided use service wikibase:around
  if (!is.na(within_distance[[1]][1])) {
    if (length(within_distance[[1]][["center"]]) == 1 && is.character(within_distance[[1]][["center"]])) {
      center = paste0(within_distance[[1]][["center"]],".\n")
    } else {
      center = paste0("'Point(", within_distance[[1]][["center"]][1]," ", within_distance[[1]][["center"]][2],")'^^geo:wktLiteral.\n")
    }
    new_triple = paste0("SERVICE wikibase:around {\n",
                       new_triple,"\n",
                       "bd:serviceParam wikibase:center ",
                       center,
                       "bd:serviceParam wikibase:radius '",
                       within_distance[[1]][["radius"]],
                       "'.\n}"
    )
  }

  glue::glue("{part_body}\n{new_triple}")
}
