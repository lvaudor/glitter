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
#' @param id a Wikidata ID, either of an item ("Qxxxxx") or of a property ("Pxxxxx"), or the item itself.
#' @param with_labels whether the labels for Wikidata items should be included in the result
#' @export
#' @examples
#' thing=get_thing("Q431603")
#' get_claims(thing, with_labels=TRUE)
get_claims=function(id, with_labels=FALSE){
  if(class(id)=="character"){thing=get_thing(id)}else{thing=id}
  claims=thing %>%
    purrr::map("claims") %>%
    .[[1]] %>%
    purrr::map("mainsnak") %>%
    purrr::map_df(get_one_claim)  %>%
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
#' @param explicit T or F, whether or not to include all non-anonymous elements in results table
#' @export
#' @examples
#' get_triplets(subject="?subject",verb="wdt:P17",object="wd:Q35", limit=10)
#' get_triplets(subject="wd:Q456", verb="wdt:P17", object="?country")
#' get_triplets(subject="wd:Q456", verb="?prop", object="wd:Q142")
#' get_triplets(subject="wd:Q456", verb="wdt:P1082", object="?pop")
#' purrr::map_df(paste0("wd:",c("Q90","Q456","Q23482")),get_triplets,verb="wdt:P1082",explicit=TRUE)
get_triplets=function(subject="?subject",verb="?verb",object="?object",limit=10,send_query=TRUE,explicit=FALSE){
  limit=as.character(limit)
  is_anonymous=function(query_var){
    if(stringr::str_sub(query_var,1,1)=="?"){return(TRUE)}else{return(FALSE)}
  }
  vars=""
  if(is_anonymous(subject)){vars=paste0(vars," ",subject," ",subject,"Label")}
  if(is_anonymous(   verb)){vars=paste0(vars," ",   verb," ",   verb,"Label")}
  if(is_anonymous( object)){vars=paste0(vars," ", object," ", object,"Label")}
  query=glue::glue('SELECT {vars}
  WHERE
  {{
    {subject} {verb} {object}.
    SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}
  }}
  LIMIT {limit}')
  if(!send_query){result=query}else{
    result=WikidataQueryServiceR::query_wikidata(query)
  }
  if(explicit){
    result=result %>%
      dplyr::mutate(verb=verb)
    if(!is_anonymous(subject)){
      result=result %>%
        dplyr::mutate(subject=subject)
    }
    if(!is_anonymous(object)){
      result=result %>%
        dplyr::mutate(object=object)
    }
  }
  return(result)
}

