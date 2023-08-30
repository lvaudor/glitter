#' Get Wikidata item or property
#' Get unformatted info from Wikidata based on an item or property id.
#' @param id a Wikidata ID, either of an item ("wd:Qxxxxx") or of a property ("wd:Pxxxxx")
#' @export
#' @examples
#' get_thing("wd:Q431603")
get_thing=function(id){
  if(is.na(id)){return(NA)}
  QorP=str_extract(id,"(?<=\\:).")
  id_short=str_extract(id,"(?<=\\:).*")
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
#' get_label("wd:Q431603", language="fr")
get_label=function(id, language="en"){
  if(is.na(id)){return(NA)}
  if(inherits(id, "character")){thing=get_thing(id)}else{thing=id}
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
#' get_description("wd:Q431603")
#' get_description("wd:Q431603", language="es")
get_description=function(id,language="en"){
  if(inherits(id, "character")){thing=get_thing(id)}else{thing=id}
  description=thing %>%
    purrr::map("descriptions") %>%
    purrr::map(language) %>%
    purrr::map_chr("value")
  return(description)
}

#' Format information about one claim (for use in get_claims)
#' @param res result
#' @noRd
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
#' @param with_labels Whether to keep labels (Boolean)
#' @export
#' @examples
#' get_claims("wd:Q431603")
get_claims=function(id, with_labels = FALSE){
  claims = spq_add(.query = NULL,
    glue::glue("{id} ?prop ?val")) %>%
    spq_label("val") %>%
    spq_add("?item wikibase:directClaim ?prop") %>%
    spq_perform() %>%
    dplyr::left_join(wd_properties,by=c("prop"="id")) %>%
    dplyr::select(property=.data$item,
           propertyLabel=.data$label,
           value=.data$val,
           valueLabel=.data$val_label,
           propertyType=.data$type,
           propertyDescription=.data$description,
           propertyAltLabel=.data$altLabel)
  return(claims)
}

utils::globalVariables("wd_properties")

#' Get description of Wikidata thing
#' @param id a Wikidata ID, either of an item ("wd:Qxxxxx") or of a property ("wd:Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @param with_labels Whether to keep labels (Boolean)
#' @export
#' @examples
#' get_info("wd:Q431603")
get_info=function(id,language="en",with_labels=FALSE){
  if(inherits(id, "character")){thing=get_thing(id)}else{thing=id}
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
    dplyr::filter(.data$property==property_name)
  return(that_claim)
}

