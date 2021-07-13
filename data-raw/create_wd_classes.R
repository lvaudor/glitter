subclasses=subclasses_of("wd:Q35120",include_self=TRUE)
subclasses_start=subclasses
while(nrow(subclasses_start)!=0){
  classes_to_search=unique(subclasses_start$classes)
  result=list()
  for(i in 259627:length(classes_to_search)){
    print(i)
    result_tmp=subclasses_of(classes_to_search[i])
    print(result_tmp)
    result=c(result,result_tmp)
  }
  #subclasses_end=purrr::map_df(unique(subclasses_start$classes),safely(subclasses_of))  %>%
  #  unique()
  print(nrow(subclasses_end))
  if(nrow(subclasses_end)>0){
    subclasses=bind_rows(subclasses,
                         subclasses_end)
  }
  subclasses_start=subclasses_end
}

saveRDS(unique(subclasses),"data-raw/subclasses.RDS")
edges=subclasses

nodes=edges %>%
  select(classes, classesLabel) %>%
  unique() %>%
  mutate(n=count_items(classes))

t1=Sys.time()
purrr::map_df(unique(subclasses_start$classes[1:10]),subclasses_of)  %>%
  unique()
Sys.time()-t1
