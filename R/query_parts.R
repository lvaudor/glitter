is_anonymous=function(query_var){
  if(is.na(query_var)|is.null(query_var)){return(FALSE)}
  if(stringr::str_sub(query_var,1,1)=="?"){return(TRUE)}else{return(FALSE)}
}

build_part_select=function(query=NA,subject,verb,object,label=NA){
  if(!is.na(query[1])){
    part_select=query$select
  }else{
    part_select=c()
  }
  for(element in list(subject,verb,object)){
    if(is_anonymous(element)){
      part_select=c(part_select, element)
      if(element %in% label){
        part_select=c(part_select,paste0(element,"Label"))
      }
    }
  }
  part_select=unique(part_select)
  return(part_select)
}
#' Builds the body part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param optional whether to make the statement optional (defaults to FALSE)
#' @param within_box if provided, north-west and south-east coordinates of bounding box for the triplet query.
#' @param within_distance if provided, north-west and south-east coordinates of bounding box for the triplet query.
#' @examples
#' recitR::build_part_body(query=NA,subject="?city",verb="wdt:P625",object="?coords",
#' within_box=list(c(-125,35),c(-120,30)))
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

build_part_service=function(query=NA){
  if(!is.na(query[1])){
    part_service=query$service
  }else{
    part_service='SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }'
  }
  return(part_service)
}

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
