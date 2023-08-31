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
  result=list(label=label,
              description=description)
  return(result)
}
