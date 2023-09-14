# within_distance is not broken

    Code
      spq_init() %>% spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>% spq_label(city) %>%
        spq_mutate(coords = wdt::P625(city), .within_distance = list(center = c(long = 4.84,
          lat = 45.76), radius = 5))
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?city (COALESCE(?city_labell,'') AS ?city_label) ?coords
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
      
      }
      

