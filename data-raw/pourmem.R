library(igraph)
library(tidygraph)
library(ggraph)
subclasses=readRDS("data-raw/subclasses.RDS")
get_from_id=function(id){
  tib=subclasses %>%
    filter(from==id) %>%
    mutate(type="below")
  return(tib)
}
get_to_id=function(id){
  tib=subclasses %>%
    filter(to==id) %>%
    mutate(type="above")
}



build_graph=function(id,step_max){
    df_start=tibble(NULL)
    step=1
    df_end=bind_rows(get_from_id(id),
                     get_to_id(id)) %>%
      mutate(step=step)
    while(nrow(df_end)>nrow(df_start) & step<step_max){
      df_start=df_end
      step=step+1
      to=purrr::map_df(df_start$to,get_from_id)
      from=purrr::map_df(df_start$from,get_to_id)
      df_end=bind_rows(df_start,
                       to %>% mutate(step=step),
                       from %>% mutate(step=step))
    }

    df_edges=df_end %>%
      filter(step<=step_max)
    df_nodes=df_edges %>%
      select(classes,classesLabel,type) %>%
      unique() %>%
      mutate(id=1:n())

    df_edges=df_edges %>%
      select(from_wd=from,
             to_wd=to) %>%
      left_join(df_nodes %>% select(id,classes),
                by=c("to_wd"="classes")) %>%
      mutate(to=id) %>%
      select(-id) %>%
      left_join(df_nodes %>% select(id,classes),
                by=c("from_wd"="classes")) %>%
      mutate(from=id) %>%
      select(-id) %>%
      select(from,to) %>%
      na.omit() %>%
      filter(from!=to)

    tib_g=tbl_graph(nodes=df_nodes,
                    edges=df_edges,
                    directed=TRUE)
  return(tib_g)
}

show_graph=function(tib_g,layout="sugiyama"){
  p=ggraph(tib_g, layout=layout) +
    geom_edge_link(arrow = arrow(length = unit(4, 'mm'))) +
    geom_node_label(aes(label=classesLabel,
                        #size=log(n),
                        fill=type),alpha=0.5)+
    coord_flip()
  return(p)
}
tib_g=build_graph(id="wd:Q431603",step_max=3,layout="kk")
show_graph(tib_g)
#
