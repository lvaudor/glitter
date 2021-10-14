
#' Compose query parts for triplets with subject verb object.
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
#' @param language the language in which the labels will be provided (defaults to "en" for English)
#' @export
#' @examples
#' # find the cities
#' add_triplets(t="?city wdt:P31/wdt:P279* wd:Q515",label=c("?city")) %>%
#' # and their populations
#' add_triplets(t="?city wdt:P1082 ?pop", required=FALSE) %>%
#' # in a bounding box
#' add_triplets(t="?city wdt:P625 ?coords",within_box=list(southwest=c(3,43),northeast=c(7,47))) %>%
#' # limit to 10 lines
#' spq_head(n=10) %>%
#' send()
#'
#' # find the individuals of the species
#' add_triplets(t="?mayor wdt:P31 ?species") %>%
#' # dog, cat or chicken
#' add_triplets(t="?species %in% c('wd:144','wd:146', 'wd:780')") %>%
#' # who occupy the function
#' add_triplets(t="?mayor p:P39 ?node") %>%
#' # of mayor
#' add_triplets(t="?node ps:P39 wd:Q30185") %>%
#' # of some places
#' add_triplets(t="?node pq:P642 ?place") %>%
#' send()
add_triplets=function(query=NULL,
                      triplet=NULL,
                      subject=NULL,
                      verb=NULL,
                      object=NULL,
                      prefixes=NULL,
                      required=TRUE,
                      label=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA),
                      language="en"){
  elts=decompose_triplet(triplet=triplet,subject=subject,verb=verb,object=object)
  query_parts=list(prefixes=build_part_prefixes(query,prefixes),
                   select=build_part_select(query,
                                            elts$subject,elts$verb,elts$object,
                                            label),
                   body=build_part_body(query,
                                        elts$subject,elts$verb,elts$object,
                                        required,
                                        within_box=within_box, within_distance=within_distance),
                   service=build_part_service(query,language),
                   filter=query$filter,
                   limit="",
                   group_by="",
                   order_by="")
  return(query_parts)
}
