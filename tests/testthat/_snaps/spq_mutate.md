# spq_mutate works

    Code
      query %>% spq_add("wd:Q331676 wdt:P1843 ?statement") %>% spq_mutate(lang = lang(
        statement))
    Output
      
      SELECT ?statement (lang(?statement) AS ?lang)
      WHERE{
      
      wd:Q331676 wdt:P1843 ?statement.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

