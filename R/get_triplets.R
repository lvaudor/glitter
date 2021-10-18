#' Get triplets with subject verb object.
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit the max number of items sent back
#' @param within_box if provided, rectangular bounding box for the triplet query. Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query. Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers. The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param keep_track element to add as a column in result to track which item the information refers to
#' @export
#' @examples
#' get_triplets(s="wd:Q456",v="wdt:P625",o="?coords")
#' get_triplets(t="wd:Q456 wdt:P625 ?coords")
#' get_triplets(t="wd:Q456 wdt:P625 ?coords", keep_track="subject")
get_triplets=function(triplet=NULL,
                      subject=NULL,
                      verb=NULL,
                      object=NULL,
                      required=TRUE,
                      label=NA,
                      limit=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA),
                      keep_track=NA){
  query=add_triplets(query=NULL,
                     triplet=triplet,
                     subject=subject,
                     verb=verb,
                     object=object,
                     required=required,
                     label=label,
                     within_box=within_box,
                     within_distance=within_distance)
  if(!is.na(limit)){query=query %>% spq_head(n=limit)}

  tib=query %>% send()
  if(!is.na(keep_track)){
    track = switch(keep_track,
                   "subject"=subject,
                   "object"=object,
                   "verb"=verb)
    if(is.null(tib)){
      tib=tibble::tibble(tracking=NA)
    }
    tib=tib %>%
      mutate(tracking=rep(track,nrow(tib)))
  }
  return(tib)
}
