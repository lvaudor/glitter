#' Get Wikidata item or property
#' Get unformatted info from Wikidata based on an item or property id.
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx")
#' @export
#' @examples
#' get_thing("Q431603")
get_thing=function(id){
  if(is.na(id)){return(NA)}
  QorP=stringr::str_sub(id,1,1)
  if(QorP=="Q"){thing=WikidataR::get_item(id)}
  if(QorP=="P"){thing=WikidataR::get_property(id)}
  return(thing)
}

#' Get label of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of label, defaults to English ("en")
#' @export
#' @examples
#' thing=get_thing("Q431603")
#' get_label(thing)
get_label=function(id, language="en"){
  if(is.na(id)){return(NA)}
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  label=thing %>%
    purrr::map("labels") %>%
    purrr::map(language) %>%
    purrr::map_chr("value")

  return(label)
}

#' Get description of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @export
#' @examples
#' thing=get_thing("Q431603")
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
#' @param res
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
  # get_claims=function(thing)
  # if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  # claims=thing %>%
  #   purrr::map("claims") %>%
  #   .[[1]] %>%
  #   purrr::map("mainsnak") %>%
  #   purrr::map_df(get_one_claim)  %>%
  #   bind_rows()
  # if(with_labels){
  #   claims=claims %>%
  #     mutate(propertyLabel=purrr::map_chr(property,get_label)) %>%
  #     mutate(value_for_label=case_when(type=="wikibase-entityid"~value,
  #                                      TRUE~NA_character_)) %>%
  #     mutate(valueLabel=purrr::map_chr(value_for_label,get_label))
  # }
  return(claims)
}

#' Get description of Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @export
#' @examples
#' thing=get_thing("Q431603")
#' get_info(thing)
get_info=function(id,language="en",with_labels=FALSE){
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  label=get_label(thing)
  description=get_description(thing)
  claims=get_claims(thing, with_labels=with_labels)
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
#' Lisieux=get_thing("Q188743")
#' get_claim(Lisieux, "P625")
get_claim=function(id, property_name="P31"){
  claims=get_claims(id)
  that_claim=claims %>%
    dplyr::filter(property==property_name)
  return(that_claim)
}

#' Get triplets with subject verb object.
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param label a vector of variables for which to include a label column (defaults to NA)
#' @param limit
#' @param within_box if provided, rectangular bounding box for the triplet query.
#' Provided as list(southwest=c(long=...,lat=...),northeast=c(long=...,lat=...))
#' @param within_distance if provided, circular bounding box for the triplet query.
#' Provided as list(center=c(long=...,lat=...), radius=...), with radius in kilometers.
#' The center can also be provided as a variable (for instance, "?location") for the center coordinates to be retrieved directly from the query.
#' @export
#' @examples
#' get_triplets(subject="?city",verb="wdt:P31/wdt:P279*",object="wd:Q515", label=c("?city"), limit=10)
get_triplets=function(subject,verb,object,optional=FALSE, label=NA, limit=NA,
                      within_box=c(NA,NA),
                      within_distance=c(NA,NA)){
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
    return(tib)
}
