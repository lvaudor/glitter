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
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "film") %>% spq_add(
        "?film wdt:P577 ?date") %>% spq_mutate(date = year(date)) %>% spq_head(10)
    Warning <lifecycle_warning_deprecated>
      The `.label` argument of `spq_add()` is deprecated as of glitter 0.2.0.
      i Ability to use `.label` will be dropped in next release, use `spq_label()` instead.
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?film (YEAR(?date0) AS ?date) (COALESCE(?film_labell,'') AS ?film_label)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      ?film wdt:P577 ?date0.
      
      }
      
      LIMIT 10

