#' Get Wikidata item or property
#' Get unformatted info from Wikidata based on an item or property id.
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx")
#' @export
#' @examples
#' get_thing("Q431603")
get_thing=function(id){
  if(is.na(id)){return(NA)}
  QorP=stringr::str_extract(id,"(?<=\\:).")
  id_short=stringr::str_extract(id,"(?<=\\:).*")
  if(QorP=="Q"){thing=WikidataR::get_item(id_short)}
  if(QorP=="P"){thing=WikidataR::get_property(id_short)}
  return(thing)
}

#' Get label of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of label, defaults to English ("en")
#' @export
#' @examples
#' get_label("wd:Q431603")
get_label=function(id, language="en"){
  if(is.na(id)){return(NA)}
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  info=thing %>%
    purrr::map("labels")
  if(language %in% names(info[[1]])) {
    label=info %>%
    purrr::map(language) %>%
    purrr::map_chr("value")
  }else{return(NA)}
  return(label)
}

#' Get description of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @export
#' @examples
#' thing=get_thing("wd:Q431603")
#' get_description(thing)
get_description=function(id,language="en"){
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  description=thing %>%
    purrr::map("descriptions") %>%
    purrr::map(language) %>%
    purrr::map_chr("value")
  return(description)
}

#' Format information about one claim (for use in get_claims)
#' @param res result
get_one_claim=function(res){
  datavalue=res$datavalue
  type=unique(datavalue$type)
  if(type=="wikibase-entityid"){
    value=datavalue$value$id
  }
  if(type=="globecoordinate"){
    value=paste0("Point(",
                 datavalue$value$latitude,
                 " ",
                 datavalue$value$longitude,
                 ")")
  }
  if(type=="quantity"){
    value=datavalue$value$amount
  }
  if(type=="time"){
    value=datavalue$value$time
  }
  if(type=="monolingualtext"){
    value=datavalue$value$text
  }
  if(type=="string"){
    value=datavalue$value
  }
  result=tibble::tibble(property=res$property,
                     type=rep(type,nrow(res)),
                     value=value)
  return(result)
}

#' Get claims regarding one Wikidata thing
#' @param id a Wikidata ID, either of an item ("wd:Qxxxxx") or of a property ("wdt:Pxxxxx"), or the item itself.
#' @export
#' @examples
#' get_claims("wd:Q431603")
get_claims=function(id, with_labels=FALSE){
  claims=add_triplets(query=NA,
                     subject=id,
                     verb="?prop",
                     object="?val",
                     label=c("?val")) %>%
    add_triplets(subject="?item",
                 verb="wikibase:directClaim",
                 object="?prop") %>%
    build_sparql() %>%
    send_sparql() %>%
    left_join(wd_properties,by=c("item"="id")) %>%
    select(property=item,
           propertyLabel=label,
           value=val,
           valueLabel=valLabel,
           propertyType=type,
           propertyDescription=description,
           propertyAltLabel=altLabel)
  return(claims)
}

#' Get description of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @export
#' @examples
#' get_info("wd:Q431603")
get_info=function(id,language="en",with_labels=FALSE){
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  label=get_label(thing)
  description=get_description(thing)
  claims=get_claims(id, with_labels=with_labels)
  result=list(label=label,
              description=description,
              claims=claims)
  return(result)
}

#' Get claims regarding one Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param property_name the name of property to get
#' @export
#' @examples
#' get_claim("wd:Q188743", "wd:P625")
get_claim=function(id, property_name="wd:P31"){
  claims=get_claims(id)
  that_claim=claims %>%
    clean_wikidata_table() %>%
    dplyr::filter(property==property_name)
  return(that_claim)
}

#' Get triplets with subject verb object.
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit the max number of items sent back
#' @param within_box if provided, rectangular bounding box for the triplet query. Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query. Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers. The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @param track element to add as a column in result to track which item the information refers to
#' @export
#' @examples
#' get_triplets(subject="?city",verb="wdt:P31/wdt:P279*",object="wd:Q515", label=c("?city"), limit=10)
#' get_triplets(subject="wd:Q355",verb="wdt:P625",object="?coords", track="object")
get_triplets=function(subject="?subject",
                      verb="?verb",
                      object="?object",
                      optional=FALSE, label=NA, limit=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA),
                      track=NA){
    if(is.na(subject)|is.na(verb)|is.na(object)){tib=NULL}else{
      query=add_triplets(query=NA,
                         subject=subject,
                         verb=verb,
                         object=object,
                         optional=optional,
                         label=label,
                         limit=limit,
                         within_box=within_box,
                         within_distance=within_distance)
      tib=query %>%
        build_sparql() %>%
        send_sparql()
    }
    if(!is.na(track)){
      track = switch(track,
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
