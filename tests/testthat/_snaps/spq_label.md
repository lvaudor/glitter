# spq_label() works

    Code
      spq_init() %>% spq_add("?mayor wdt:P31 ?species") %>% spq_set(species = c(
        "wd:Q144", "wd:Q146", "wd:Q780")) %>% spq_add("?mayor p:P39 ?node") %>%
        spq_add("?node ps:P39 wd:Q30185") %>% spq_add("?node pq:P642 ?place") %>%
        spq_label(mayor, place, .languages = "nl")
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?mayor ?node ?place ?species (COALESCE(?mayor_labell,'') AS ?mayor_label) (lang(?mayor_labell) AS ?mayor_label_lang) (COALESCE(?place_labell,'') AS ?place_label) (lang(?place_labell) AS ?place_label_lang)
      WHERE {
      
      ?mayor wdt:P31 ?species.
      ?mayor p:P39 ?node.
      ?node ps:P39 wd:Q30185.
      ?node pq:P642 ?place.
      OPTIONAL {
      	?mayor rdfs:label ?mayor_labell.
      	FILTER(langMatches(lang(?mayor_labell), 'nl'))
      }
      
      OPTIONAL {
      	?place rdfs:label ?place_labell.
      	FILTER(langMatches(lang(?place_labell), 'nl'))
      }
      
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_init() %>% spq_add("?mayor wdt:P31 ?species") %>% spq_set(species = c(
        "wd:Q144", "wd:Q146", "wd:Q780")) %>% spq_add("?mayor p:P39 ?node") %>%
        spq_add("?node ps:P39 wd:Q30185") %>% spq_add("?node pq:P642 ?place") %>%
        spq_label(mayor, place, .languages = c("fr", "en"))
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?mayor ?node ?place ?species (COALESCE(?mayor_labell,'') AS ?mayor_label) (lang(?mayor_labell) AS ?mayor_label_lang) (COALESCE(?place_labell,'') AS ?place_label) (lang(?place_labell) AS ?place_label_lang)
      WHERE {
      
      ?mayor wdt:P31 ?species.
      ?mayor p:P39 ?node.
      ?node ps:P39 wd:Q30185.
      ?node pq:P642 ?place.
      OPTIONAL {
      	?mayor rdfs:label ?mayor_labell.
      	FILTER(langMatches(lang(?mayor_labell), 'fr') || langMatches(lang(?mayor_labell), 'en'))
      }
      
      OPTIONAL {
      	?place rdfs:label ?place_labell.
      	FILTER(langMatches(lang(?place_labell), 'fr') || langMatches(lang(?place_labell), 'en'))
      }
      
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

