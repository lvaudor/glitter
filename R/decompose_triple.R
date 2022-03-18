#' Get elements subject, verb, object of a triple as a list.
#' @param triple the triple statement (replaces arguments subject verb and object)
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
decompose_triple = function(triple, subject, verb, object){
  # decompose triple if necessary: get three elements subject-verb-object as a list
  if (!is.null(triple)) {
    # if triple is subject==object then introduce spaces: subject == object
    if(stringr::str_detect(triple,"\\s*==\\s*")){
      triple=stringr::str_replace(triple,"\\s*==\\s*"," == ")
    }
    # if one part of triple is of the type 'Cristiano_Ronaldo'@en
    if(stringr::str_detect(triple,"[\'\"].*[\'\"]")){
      part_pb=stringr::str_extract(triple,"[\'\"].*[\'\"]")
      part_ok=stringr::str_replace_all(part_pb,"\\s","_")
      triple=stringr::str_replace(triple,part_pb,part_ok)
    }

    # decompose triple, splitting elements based on spaces
    elements=stringr::str_split(triple,"\\s+") %>% unlist()


    elements=list(subject=elements[1],
                  verb=elements[2],
                  object=elements[3])
    }else{
    elements=list(subject=subject,
                  verb=verb,
                  object=object)
  }
  # tests for syntax error in subject verb and object
  elements_interpreted=purrr::map(elements,interpret_svo)
  elements_correct=purrr::map_lgl(elements_interpreted,is_svo_correct)
  if(!all(elements_correct)){
      stop(glue::glue("Element {elements[!elements_correct][1]} is incorrectly stated."))
  }
  return(elements_interpreted)
}
