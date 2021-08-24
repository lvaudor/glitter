is_variable=function(query_var){
  if(is.na(query_var)|is.null(query_var)){return(FALSE)}
  if(stringr::str_sub(query_var,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}

#' Builds the "select" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "wd:Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "wd:Q456"))
#' @param label whether to get the label associated with the mentioned item
#' @examples
#' build_part_select(query=NA,subject="?city",verb="wdt:P625",object="?coords", label="?city")
build_part_select=function(query=NA,subject,verb,object,label=NA){
  if(!is.na(query[1])){
    part_select=query$select
  }else{
    part_select=c()
  }
  for(element in list(subject,verb,object)){
    if(is_variable(element)){
      part_select=c(part_select, element)
      if(element %in% label){
        part_select=c(part_select,paste0(element,"Label"))
      }
    }
  }
  part_select=unique(part_select)
  return(part_select)
}
#' Builds the "body" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param optional whether to make the statement optional (defaults to FALSE)
#' @param within_box if provided, north-west and south-east coordinates of bounding box for the triplet query.
#' @param within_distance if provided, north-west and south-east coordinates of bounding box for the triplet query.
#' @examples
#' build_part_body(query=NA,subject="?city",verb="wdt:P625",object="?coords", within_box=list(c(-125,35),c(-120,30)))
build_part_body=function(query=NA,subject,verb,object,optional=FALSE,
                         within_box=c(NA,NA),within_distance=c(NA,NA)){
  if(!is.na(query[1])){
    part_body=query$body
  }else{
    part_body=""
  }
  new_triplet=glue::glue("{subject} {verb} {object}.")
  if(optional){
    new_triplet=paste0("OPTIONAL {",new_triplet,"}")
  }
  if(!is.na(within_box[[1]][1])){
    new_triplet=paste0("SERVICE wikibase:box {\n",
                       new_triplet,"\n",
                       "bd:serviceParam wikibase:cornerSouthWest 'Point(",
                       within_box$southwest[1]," ",within_box$southwest[2],
                       ")'^^geo:wktLiteral.\n",
                       "bd:serviceParam wikibase:cornerNorthEast 'Point(",
                       within_box$northeast[1]," ",within_box$northeast[2],
                       ")'^^geo:wktLiteral.\n}"
                       )
  }
  if(!is.na(within_distance[[1]][1])){
    if(length(within_distance$center)==1 & is.character(within_distance$center)){
      center=paste0(within_distance$center,".\n")
    }else{
      center=paste0("'Point(",within_distance$center[1]," ",within_distance$center[2],")'^^geo:wktLiteral.\n")
    }
    new_triplet=paste0("SERVICE wikibase:around {\n",
                       new_triplet,"\n",
                       "bd:serviceParam wikibase:center ",
                       center,
                       "bd:serviceParam wikibase:radius '",
                       within_distance$radius,
                       "'.\n}"
    )
  }
  part_body=glue::glue("{part_body}\n
                       {new_triplet}")
  return(part_body)
}

#' Builds the "service" part of a query.
#' @param query a list with elements of the query
#' @examples
#' build_part_service(query=NA, language="fr")
build_part_service=function(query=NA, language="en"){
  if(!is.na(query[1])){
    part_service=query$service
  }else{
    part_service=paste0(
      'SERVICE wikibase:label { bd:serviceParam wikibase:language "',
      language,
      '".}')
  }
  return(part_service)
}

#' Builds the "filter" part of a query.
#' @param query a list with elements of the query*
#' @param expressions the vector of filtering expressions to apply
#' @examples
#' build_part_filter(query, c("?pop >= 3000","?country==wd:Q142"))
build_part_filter=function(query=NA, expressions){
  if(!is.na(query[1])){
    part_filter=query$filter
  }else{
    part_filter=c()
  }
  if(!is.na(expressions)){
    part_filter_to_add=paste0("FILTER(",expressions,")\n")%>%
      paste0(collapse="")
    part_filter=paste0(part_filter,part_filter_to_add)
  }else{
    part_filter=part_filter
  }

  return(part_filter)
}

#' Builds the "limit" part of a query.
#' @param query a list with elements of the query
#' @examples
#' build_part_limit(query=NA, limit=5)
build_part_limit=function(query,limit=NA){
  if(!is.na(query[1])){
    part_limit=query$limit
  }else{
    if(is.na(limit)){
      part_limit=""}
    else{
      part_limit=glue::glue("LIMIT {as.character(limit)}")
    }
  }
  return(part_limit)
}
