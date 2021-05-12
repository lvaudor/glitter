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


get_one_claim=function(dat){
  res=dat$mainsnak
  if(class(res$datavalue$value)=="data.frame"){
    res$datavalue=res$datavalue %>% mutate(value=value$id)
  }
  res=bind_cols(property=res$property,res$datavalue)
  return(res)
}

#' Get claims regarding one Wikidata thing
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param language language of description, defaults to English ("en")
#' @export
#' @examples
#' thing=get_thing("Q431603")
#' get_claims(thing, with_labels=TRUE)
get_claims=function(id, with_labels=FALSE){
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  claims=thing %>%
    purrr::map("claims")
  claims=claims[[1]] %>%
    purrr::map_df(get_one_claim) %>%
    bind_rows()
  if(with_labels){
    claims=claims %>%
      mutate(propertyLabel=purrr::map_chr(property,get_label)) %>%
      mutate(value_for_label=case_when(type=="wikibase-entityid"~value,
                                       TRUE~NA_character_)) %>%
      mutate(valueLabel=purrr::map_chr(value_for_label,get_label))
  }
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


