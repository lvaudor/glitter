# within_distance is not broken

    Code
      spq_init() %>% spq_add("?city wdt:P31/wdt:P279* wd:Q486972", .label = "?city") %>%
        spq_mutate(coords = wdt::P625(city), .within_distance = list(center = c(long = 4.84,
          lat = 45.76), radius = 5))
    Warning <lifecycle_warning_deprecated>
      The `.label` argument of `spq_add()` is deprecated as of glitter 0.2.0.
      i Ability to use `.label` will be dropped in next release, use `spq_label()` instead.
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?city ?coords (COALESCE(?city_labell,'') AS ?city_label) (lang(?city_labell) AS ?city_label_lang)
      WHERE {
      
      ?city wdt:P31/wdt:P279* wd:Q486972.
      OPTIONAL {
      	?city rdfs:label ?city_labell.
      	FILTER(lang(?city_labell) IN ('en'))
      }
      
      SERVICE wikibase:around {
      ?city wdt:P625 ?coords.
      bd:serviceParam wikibase:center 'Point(4.84 45.76)'^^geo:wktLiteral.
      bd:serviceParam wikibase:radius '5'.
      }
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

