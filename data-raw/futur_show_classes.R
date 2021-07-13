library(igraph)
library(tidygraph)
library(ggraph)

build_graph_classes=function(id){
    subclasses=subclasses_of(id,include_self=TRUE)
    subclasses_start=subclasses
    while(nrow(subclasses_start)!=0){
      subclasses_end=purrr::map_df(unique(subclasses_start$classes),subclasses_of)  %>%
        unique()
      if(nrow(subclasses_end)>0){
        subclasses=bind_rows(subclasses,
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
        superclasses=bind_rows(superclasses,
                               superclasses_end)
      }
      superclasses_start=superclasses_end
    }

    table_edges=bind_rows(subclasses %>%
                            mutate(type=case_when(from==to~"og",
                                                  from!=to~"sub")),
                          superclasses %>%
                            mutate(type="sup"))
    table_nodes=table_edges %>%
      select(type,classes, classesLabel) %>%
      unique() %>%
      mutate(n=count_items(classes))%>%
      mutate(id=1:n())
    table_edges=table_edges %>%
      select(from_wd=from,
             to_wd=to) %>%
      left_join(table_nodes %>% select(id,classes),
                by=c("to_wd"="classes")) %>%
      mutate(to=id) %>%
      select(-id) %>%
      left_join(table_nodes %>% select(id,classes),
                by=c("from_wd"="classes")) %>%
      mutate(from=id) %>%
      select(-id) %>%
      select(from,to) %>%
      na.omit() %>%
      filter(from!=to)
    tib_g=tbl_graph(nodes=table_nodes,
                    edges=table_edges)
    return(tib_g)
}

show_graph_classes=function(tib_g,n_min=10,layout="kk"){
  tib_g_light=tib_g %>%
    filter(n>n_min)
  g=ggraph(tib_g_light, layout=layout) +
    geom_edge_link(arrow = arrow(length = unit(4, 'mm'))) +
    geom_node_label(aes(label=classesLabel,size=log(n),fill=type),alpha=0.5)+
    coord_flip()
  return(g)
}

tib_g=build_graph_classes("wd:Q627272")
show_graph_classes(tib_g,layout="kk")
show_graph_classes(tib_g,layout="sugiyama")
