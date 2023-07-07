# spq_set() works

    Code
      spq_init() %>% spq_set(species = c("wd:Q144", "wd:Q146", "wd:Q780"), mayorcode = "wd:Q30185")
    Output
      
      SELECT *
      WHERE {
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      VALUES ?mayorcode {wd:Q30185}
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

