# spq_assemble() works - bindings

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P921 ?subject") %>% spq_label(subject) %>% spq_group_by(film) %>%
        spq_summarise(subject_label_concat = str_c(subject_label, sep = "; ")) %>%
        spq_head(10)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?film (GROUP_CONCAT(?subject_label;SEPARATOR="; ") AS ?subject_label_concat)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P921 ?subject.
      OPTIONAL {
      	?subject rdfs:label ?subject_labell.
      	FILTER(lang(?subject_labell) IN ('en'))
      }
      
      BIND(COALESCE(?subject_labell,'') AS ?subject_label)
      
      }
      GROUP BY ?film
      
      LIMIT 10

---

    Code
      spq_init() %>% spq_add("?item wdt:P31 wd:Q13442814") %>% spq_label(item) %>%
        spq_filter(str_detect(str_to_lower(item_label), "wikidata")) %>% spq_head(n = 5)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?item (COALESCE(?item_labell,'') AS ?item_label)
      WHERE {
      
      ?item wdt:P31 wd:Q13442814.
      OPTIONAL {
      	?item rdfs:label ?item_labell.
      	FILTER(lang(?item_labell) IN ('en'))
      }
      
      BIND(COALESCE(?item_labell,'') AS ?item_label)
      FILTER(REGEX(LCASE(?item_label),"wikidata"))
      }
      
      LIMIT 5

# spq_assemble() detects undefined variables in filter

    Code
      spq_init() %>% spq_filter(lang(itemTitleLOOKTYPO) == "en") %>% spq_assemble()
    Error <rlang_error>
      Can't filter on undefined variables: ?itemTitleLOOKTYPO
      i You haven't mentioned them in any triple, VALUES, mutate.

# spq_assemble() called from printing isn't strict

    Code
      spq_init() %>% spq_filter(lang(itemTitleLOOKTYPO) == "en")
    Output
      
      SELECT *
      WHERE {
      
      FILTER(lang(?itemTitleLOOKTYPO)="en")
      }
      

