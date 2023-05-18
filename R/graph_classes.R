#' Build the graph of sub/superclasses
#' @param id the id of class
#' @importFrom rlang .data `%||%` `:=`
#' @export
#' @examples
#' \dontrun{
#' tib_g=build_graph_classes("wd:Q627272")
#' }
#' @noRd
build_graph_classes=function(id){
  subclasses=subclasses_of(id,include_self=TRUE)
  subclasses_start=subclasses
  while(nrow(subclasses_start)!=0){
    subclasses_end=purrr::map_df(unique(subclasses_start$classes),subclasses_of)  %>%
      unique()
    if(nrow(subclasses_end)>0){
      subclasses=dplyr::bind_rows(subclasses,
                                  subclasses_end)
    }
    subclasses_start=subclasses_end
  }
  superclasses=superclasses_of(id,include_self=FALSE)
  superclasses_start=superclasses
  while(nrow(superclasses_start)!=0){
    superclasses_end=purrr::map_df(unique(superclasses_start$classes),superclasses_of)  %>%
      unique()
    if(nrow(superclasses_end)>0){
      superclasses=dplyr::bind_rows(superclasses,
                                    superclasses_end)
    }
    superclasses_start=superclasses_end
  }

  table_edges=dplyr::bind_rows(subclasses %>%
                                 dplyr::mutate(type=dplyr::case_when(.data$from==.data$to~"og",
                                                                     .data$from!=.data$to~"sub")),
                        superclasses %>%
                          dplyr::mutate(type="sup"))
  table_nodes=table_edges %>%
    dplyr::select(.data$type, .data$classes, .data$classesLabel) %>%
    unique() %>%
    dplyr::mutate(n=count_items(.data$classes))%>%
    dplyr::mutate(id=1:dplyr::n())
  table_edges=table_edges %>%
    dplyr::select(from_wd=.data$from,
                  to_wd=.data$to) %>%
    dplyr::left_join(table_nodes %>%
                       dplyr::select(.data$id,.data$classes),
                     by=c("to_wd"="classes")) %>%
    dplyr::mutate(to=id) %>%
    dplyr::select(-id) %>%
    dplyr::left_join(table_nodes %>% dplyr::select(.data$id,.data$classes),
                     by=c("from_wd"="classes")) %>%
    dplyr::mutate(from=id) %>%
    dplyr::select(-.data$id) %>%
    dplyr::select(.data$from,.data$to) %>%
    stats::na.omit() %>%
    dplyr::filter(.data$from!=.data$to)
  tib_g=tidygraph::tbl_graph(nodes=table_nodes,
                             edges=table_edges)
  return(tib_g)
}

#' Show the graph of sub/superclasses
#' @param tib_g tib_g
#' @param layout layout of the graph for instance "kk" or "sugiyama"
#' @param n_min minimal number
#' @examples
#' \dontrun{
#' tib_g=build_graph_classes("wd:Q627272")
#' show_graph_classes(tib_g,layout="kk")
#' show_graph_classes(tib_g,layout="sugiyama")
#' }
#' @noRd
show_graph_classes=function(tib_g,n_min=10,layout="kk"){
  tib_g_light=tib_g %>%
    dplyr::filter(.data$n > {{ n_min }})
  g=ggraph::ggraph(tib_g_light, layout=layout) +
    ggraph::geom_edge_link(arrow = ggplot2::arrow(length = ggplot2::unit(4, 'mm'))) +
    ggraph::geom_node_label(ggplot2::aes(label=.data$classesLabel,size=log(.data$n),fill=.data$type),alpha=0.5)+
    ggplot2::coord_flip()
  return(g)
}


