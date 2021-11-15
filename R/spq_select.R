#' Select particular variables
#' @param query the query
#' @param variables the variables
#' @export
#' @examples
#' tib=spq_init() %>%
#'  spq_add("?film wdt:P31 wd:Q11424", label="?film") %>%
#'  spq_add("?film wdt:P840 ?loc", label="?loc") %>%
#'  spq_add("?film wdt:P495 ?origin", label="?origin") %>%
#'  spq_add("?film wdt:P577 ?date") %>%
#'  spq_mutate(c("?year"="year(?date)")) %>%
#'  spq_head(10) %>%
#'  spq_select("-?date") %>%
#'  send()
spq_select=function(query=NULL,
                    variables){
  prev_vars=query$select

  # positively identified variables
  plus_variables=variables %>%
    stringr::str_subset("^\\?")
  # negatively identified variables
  minus_variables=variables %>%
    stringr::str_subset("^\\-\\?") %>%
    stringr::str_remove("\\-")

  # If some variables are positively identified,
  # keep only these, else keep all
  if(length(plus_variables>0)){
    new_vars=prev_vars %>%
      subset(prev_vars %in% plus_variables)
  }else{
    new_vars=prev_vars
  }
  # If some variables are negatively identified,
  # keep all but these, else keep all
  if(length(minus_variables>0)){
    new_vars=new_vars %>%
      subset(!(new_vars %in% minus_variables))
  }
  query$select=unique(new_vars)
  return(query)
}
