#' Builds the "service" part of a query.
#' @param query a list with elements of the query
#' @param language the language in which to label variables
build_part_service=function(query=NULL,language="en"){
  part_service=""
  part_service_to_add=paste0(
      'SERVICE wikibase:label { bd:serviceParam wikibase:language "',
      language,
      '".}')
  part_service=glue::glue("{part_service} {part_service_to_add}")
  return(part_service)
}
