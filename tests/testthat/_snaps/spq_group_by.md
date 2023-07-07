# spq_group_by works with R syntax

    Code
      spq_init() %>% spq_select(population, countryLabel) %>% spq_group_by(population,
        countryLabel)
    Output
      
      SELECT ?population ?countryLabel
      WHERE {
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?population ?countryLabel
      

# spq_group_by works with R syntax - string

    Code
      spq_init() %>% spq_select(population, countryLabel) %>% spq_group_by(
        "population", "countryLabel")
    Output
      
      SELECT ?population ?countryLabel
      WHERE {
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?population ?countryLabel
      

