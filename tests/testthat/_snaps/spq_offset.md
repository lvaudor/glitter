# spq_offset() works

    Code
      spq_init() %>% spq_add("?item wdt:P31 wd:Q5") %>% spq_label(item) %>% spq_add(
        "?item wdt:P19/wdt:P131* wd:Q60") %>% spq_add(
        "?item wikibase:sitelinks ?linkcount") %>% spq_arrange(desc(linkcount)) %>%
        spq_head(42) %>% spq_offset(11)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX wikibase: <http://wikiba.se/ontology#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?item (COALESCE(?item_labell,'') AS ?item_label) ?linkcount
      WHERE {
      
      ?item wdt:P31 wd:Q5.
      OPTIONAL {
      	?item rdfs:label ?item_labell.
      	FILTER(lang(?item_labell) IN ('en'))
      }
      
      ?item wdt:P19/wdt:P131* wd:Q60.
      ?item wikibase:sitelinks ?linkcount.
      
      }
      ORDER BY DESC(?linkcount)
      LIMIT 42OFFSET 11

