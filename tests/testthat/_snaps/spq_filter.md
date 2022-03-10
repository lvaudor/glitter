# spq_filter works with SPARQL syntax

    Code
      spq_init() %>% spq_add("?item wdt:P31 wd:Q13442814") %>% spq_add(
        "?item rdfs:label ?itemTitle") %>% spq_filter(spq(
        "CONTAINS(LCASE(?itemTitle),'wikidata')")) %>% spq_filter(spq(
        "LANG(?itemTitle)='en'"))
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?item ?itemTitle
      WHERE{
      
      ?item wdt:P31 wd:Q13442814.
      ?item rdfs:label ?itemTitle.
      FILTER(CONTAINS(LCASE(?itemTitle),'wikidata'))
      FILTER(LANG(?itemTitle)='en')
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# spq_filter works with R DSL

    Code
      spq_init() %>% spq_add("?item wdt:P31 wd:Q13442814") %>% spq_add(
        "?item rdfs:label ?itemTitle") %>% spq_filter(str_detect(str_to_lower(
        itemTitle), "wikidata")) %>% spq_filter(lang(itemTitle) == "en")
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?item ?itemTitle
      WHERE{
      
      ?item wdt:P31 wd:Q13442814.
      ?item rdfs:label ?itemTitle.
      FILTER(REGEX(LCASE(?itemTitle),"wikidata"))
      FILTER(lang(?itemTitle)="en")
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# R-DSL %in%

    Code
      spq_init() %>% spq_filter(str_to_lower(as.character(scientific_name)) %in% c(
        "lala", "lili"))
    Output
      
      SELECT *
      WHERE{
      
      FILTER(LCASE(str(?scientific_name))IN("lala","lili"))
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# R-DSL & and :

    Code
      spq_init() %>% spq_filter(bound(date) & typeof(date) == xsd:dateTime)
    Output
      
      SELECT *
      WHERE{
      
      FILTER(bound(?date)&&datatype(?date)=xsd:dateTime)
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

