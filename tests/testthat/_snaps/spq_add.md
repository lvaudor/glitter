# spq_add() works, double variable

    Code
      spq_init() %>% spq_add(spq("?software p:P348/pq:P577 ?date"))
    Output
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?date ?software
      WHERE {
      
      ?software p:P348/pq:P577 ?date.
      
      }
      

# spq_add() works, trailing period

    Code
      spq_init() %>% spq_add(spq("?software pq:P577 ?date."))
    Output
      PREFIX pq: <http://www.wikidata.org/prop/qualifier/>
      SELECT ?date ?software
      WHERE {
      
      ?software pq:P577 ?date.
      
      }
      

