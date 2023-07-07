# spq_mutate works

    Code
      spq_init() %>% spq_mutate(statement = wdt::P1843(wd::Q331676)) %>% spq_mutate(
        lang = lang(statement))
    Output
      
      SELECT ?statement (lang(?statement) AS ?lang)
      WHERE {
      
      wd:Q331676 wdt:P1843 ?statement.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

