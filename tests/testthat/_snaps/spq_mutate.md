# spq_mutate works

    Code
      spq_init() %>% spq_mutate(statement = wdt::P1843(wd::Q331676)) %>% spq_mutate(
        lang = lang(statement))
    Output
      
      SELECT ?statement (lang(?statement) AS ?lang)
      WHERE {
      
      wd:Q331676 wdt:P1843 ?statement.
      
      }
      

# spq_mutate with renaming

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_label(film) %>%
        spq_add("?film wdt:P577 ?date") %>% spq_mutate(date = year(date)) %>%
        spq_head(10)
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?film (COALESCE(?film_labell,'') AS ?film_label) (YEAR(?date0) AS ?date)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      ?film wdt:P577 ?date0.
      
      }
      
      LIMIT 10

# spq_mutate with double renaming

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_label(film) %>%
        spq_add("?film wdt:P577 ?date") %>% spq_mutate(date = year(date)) %>%
        spq_mutate(date = date - 2000)
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?film (COALESCE(?film_labell,'') AS ?film_label) (?date0-2000 AS ?date)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      ?film wdt:P577 ?date00.
      BIND(YEAR(?date00) AS ?date0)
      }
      

