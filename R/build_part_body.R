#' Builds the "body" part of a query.
#' @param query a list with elements of the query
#' @param subject an anonymous variable (for instance, and by default, "?subject") or item (for instance "Q456"))
#' @param verb the property (for instance "wdt:P190")
#' @param object an anonymous variable (for instance, and by default, "?object") or item (for instance "Q456"))
#' @param optional whether to make the statement optional (defaults to FALSE)
#' @param within_box if provided, north-west and south-east coordinates of bounding box for the triplet query.
#' @param within_distance if provided, north-west and south-east coordinates of bounding box for the triplet query.
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
