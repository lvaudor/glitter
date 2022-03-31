#' Get subclasses of a Wikidata class
#' @param id the id of class
#' @param include_self whether to include class itself in the results table
#' @export
#' @examples
#' subclasses_of("wd:Q7930989")
subclasses_of=function(id, include_self=FALSE){
  classes=get_triple(subject="?classes",
                       verb="wdt:P279",
                       object=id,
                       label="?classes")
  if(is.null(classes)){classes=tibble::tibble(classes=NULL,classesLabel=NULL)}
  if(include_self){
    classes=dplyr::bind_rows(tibble::tibble(classes=id,
                                            classesLabel=get_label(id)),
                             classes)
  }
  if(nrow(classes)!=0){
    classes=classes %>%
      clean_wikidata_table() %>%
      dplyr::mutate(from=id,
                    to=classes) %>%
      dplyr::select(.data$from,.data$to,dplyr::everything())
  }
  return(classes)
}

#' Get superclasses of a Wikidata class
#' @param id the id of class
#' @param include_self whether to include class itself in the results table
#' @export
#' @examples
#' superclasses_of("wd:Q7930989")
superclasses_of=function(id, include_self=FALSE){
  classes=get_triple(subject=id,
                       verb="wdt:P279",
                       object="?classes",
                       label="?classes")
  if(is.null(classes)){classes=tibble::tibble(classes=NULL,classesLabel=NULL)}

  if(include_self){
    classes=dplyr::bind_rows(tibble::tibble(classes=id,
                                            classesLabel=get_label(id)),
                             classes)
  }
  if(nrow(classes)!=0){
    classes=classes %>%
      clean_wikidata_table()%>%
      dplyr::mutate(from=classes,
                    to=id) %>%
      dplyr::select(.data$from,.data$to,dplyr::everything())
  }
  return(classes)
}


#' Get counts of items directly in classes
#' @param classes the vector wikidata classes
#' @export
#' @examples
#' classes=c("wd:Q627272","wd:Q99527517")
#' count_items(classes)
count_items=function(classes){
  nrow_wd=function(x){
    if(is.null(x)){return(0)}else{return(nrow(x))}
  }
  n=purrr::map(.x=classes,
               ~get_triple(subject="?item",
                             verb="wdt:P31",
                             object=.x,
                             label="?item"))    %>%
    purrr::map_dbl(nrow_wd)
  return(n)
}

