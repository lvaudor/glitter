
#' Compose query parts for triplets with subject verb object.
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param required whether the existence of a value for the triplet is required or not (defaults to TRUE).
#'   If set to FALSE, then other triplets in the query are returned even if this particular triplet is missing)
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit the max number of items sent back
#' @param filter the filters to apply
#' @param within_box if provided, rectangular bounding box for the triplet query.
#'   Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query.
#'   Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers.
#'   The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param language the language in which the labels will be provided (defaults to "en" for English)
#' @export
#' @examples
#' add_triplets(s="?city",v="wdt:P31/wdt:P279*",o="wd:Q515",label=c("?city"),limit=10) %>%
#' add_triplets(s="?city",v="wdt:P1082",o="?pop", required=FALSE) %>%
#' add_triplets(s="?city",v="wdt:P625",o="?coords",within_box=list(southwest=c(3,43),northeast=c(7,47))) %>%
#' send()
add_triplets=function(query=NA,subject,verb,object,
                      prefixes=NULL,
                      required=TRUE,
                      label=NA,
                      filter=NA,
                      limit=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA),
                      language="en"){
  query_parts=list(prefixes=build_part_prefixes(query,prefixes),
                   select=build_part_select(query,subject,verb,object,label),
                   body=build_part_body(query,subject,verb,object,required,
                                        within_box=within_box, within_distance=within_distance),
                   service=build_part_service(query,language),
                   filter=build_part_filter(query, filter),
                   limit=build_part_limit(query,limit))
  return(query_parts)
}
