#' Get triple with subject verb object.
#' @param triple triple
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit the max number of items sent back
#' @param within_box if provided, rectangular bounding box for the triple query. Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triple query. Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers. The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param required whether to require this triple (Boolean)
#' @export
#' @examples
#' get_triple(s="wd:Q456",v="wdt:P625",o="?coords")
#' get_triple(t="wd:Q456 wdt:P625 ?coords")
get_triple=function(triple=NULL,
                      subject=NULL,
                      verb=NULL,
                      object=NULL,
                      required=TRUE,
                      label=NA,
                      limit=NULL,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA)){
  query=spq_add(.query=NULL,
                     .triple_pattern=triple,
                     .subject=subject,
                     .verb=verb,
                     .object=object,
                     .required=required,
                     .label=label,
                     .within_box=within_box,
                     .within_distance=within_distance)
  if(!is.null(limit)){query=query %>% spq_head(n=limit)}

  tib=query %>% spq_perform()
  return(tib)
}
