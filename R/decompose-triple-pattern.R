#' Get elements subject, verb, object of a triple pattern as a list.
#' @param triple_pattern the triple pattern statement
#' (replaces arguments subject verb and object)
#' @param subject an anonymous variable (for instance, and by default,
#' "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object")
#'  or item (for instance "wd:Q456"))
#' @noRd
decompose_triple_pattern = function(triple_pattern, subject, verb, object) {

  if (is.null(triple_pattern)) {
    elements = list(subject = subject,
      verb = verb,
      object = object)

  } else {
    # if there is a trailing period
    triple_pattern = sub("\\.$", "", triple_pattern)
    if (str_detect(triple_pattern, "\\s*==\\s*")) {
      triple_pattern = str_replace(triple_pattern, "\\s*==\\s*", " == ")
    }

    # if one part of triple_pattern is of the type 'Cristiano_Ronaldo'@en
    if (str_detect(triple_pattern, "[\'\"].*[\'\"]")) {
      part_pb = str_extract(triple_pattern, "[\'\"].*[\'\"]")
      part_ok = str_replace_all(part_pb, "\\s", "_")
      triple_pattern = str_replace(triple_pattern, part_pb, part_ok)
    }

    # decompose triple, splitting elements based on spaces
    elements = str_split(triple_pattern, "\\s+") %>% unlist()
    elements = list(
      subject = elements[1],
      verb = elements[2],
      object = elements[3]
    )
  }

  # tests for syntax error in subject verb and object
  elements_interpreted = purrr::map(elements, interpret_svo)
  elements_correct = purrr::map_lgl(elements_interpreted, is_svo_correct)

  if (!all(elements_correct)) {
      cli::cli_abort(
        "Element {elements[!elements_correct][1]} is incorrectly stated."
      )
  }

  elements_interpreted
}
