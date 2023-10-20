# spq_label() works

    Code
      spq_init() %>% spq_add("?mayor wdt:P31 ?species") %>% spq_set(species = c(
        "wd:Q144", "wd:Q146", "wd:Q780")) %>% spq_add("?mayor p:P39 ?node") %>%
        spq_add("?node ps:P39 wd:Q30185") %>% spq_add("?node pq:P642 ?place") %>%
        spq_label(mayor, place, .languages = "en$")
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX pq: <http://www.wikidata.org/prop/qualifier/>
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?mayor (COALESCE(?mayor_labell,'') AS ?mayor_label) ?node ?place (COALESCE(?place_labell,'') AS ?place_label) ?species
      WHERE {
      
      ?mayor wdt:P31 ?species.
      ?mayor p:P39 ?node.
      ?node ps:P39 wd:Q30185.
      ?node pq:P642 ?place.
      OPTIONAL {
      	?mayor rdfs:label ?mayor_labell.
      	FILTER(lang(?mayor_labell) IN ('en'))
      }
      
      OPTIONAL {
      	?place rdfs:label ?place_labell.
      	FILTER(lang(?place_labell) IN ('en'))
      }
      
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      
      }
      

---

    Code
      spq_init() %>% spq_add("?mayor wdt:P31 ?species") %>% spq_set(species = c(
        "wd:Q144", "wd:Q146", "wd:Q780")) %>% spq_add("?mayor p:P39 ?node") %>%
        spq_add("?node ps:P39 wd:Q30185") %>% spq_add("?node pq:P642 ?place") %>%
        spq_label(mayor, place, .languages = c("fr", "en"))
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX pq: <http://www.wikidata.org/prop/qualifier/>
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?mayor (COALESCE(?mayor_labell,'') AS ?mayor_label) (lang(?mayor_labell) AS ?mayor_label_lang) ?node ?place (COALESCE(?place_labell,'') AS ?place_label) (lang(?place_labell) AS ?place_label_lang) ?species
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
      
      }
      

# spq_label() for not rdfs:label

    Code
      spq_init(endpoint = "hal") %>% spq_add(
        "haldoc:inria-00362381 dcterms:hasVersion ?version") %>% spq_add(
        "?version dcterms:type ?type") %>% spq_label(type)
    Output
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX haldoc: <https://data.archives-ouvertes.fr/document/>
      SELECT ?type (COALESCE(?type_labell,'') AS ?type_label) ?version
      WHERE {
      
      haldoc:inria-00362381 dcterms:hasVersion ?version.
      ?version dcterms:type ?type.
      OPTIONAL {
      	?type skos:prefLabel ?type_labell.
      	FILTER(lang(?type_labell) IN ('en'))
      }
      
      
      }
      

# spq_label() .overwrite

    Code
      spq_init() %>% spq_add("?mayor wdt:P31 ?species") %>% spq_set(species = c(
        "wd:Q144", "wd:Q146", "wd:Q780")) %>% spq_add("?mayor p:P39 ?node") %>%
        spq_add("?node ps:P39 wd:Q30185") %>% spq_add("?node pq:P642 ?place") %>%
        spq_label(mayor, place, .languages = "en$", .overwrite = TRUE)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX pq: <http://www.wikidata.org/prop/qualifier/>
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?node ?species (COALESCE(?mayor_labell,'') AS ?mayor) (COALESCE(?place_labell,'') AS ?place)
      WHERE {
      
      ?mayor0 wdt:P31 ?species.
      ?mayor0 p:P39 ?node.
      ?node ps:P39 wd:Q30185.
      ?node pq:P642 ?place0.
      OPTIONAL {
      	?mayor0 rdfs:label ?mayor_labell.
      	FILTER(lang(?mayor_labell) IN ('en'))
      }
      
      OPTIONAL {
      	?place0 rdfs:label ?place_labell.
      	FILTER(lang(?place_labell) IN ('en'))
      }
      
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      
      }
      

# spq_label() .languages = NULL

    Code
      spq_init(endpoint = "hal") %>% spq_add("?labo dcterms:identifier ?labo_id",
        .required = FALSE) %>% spq_label(labo, .languages = NULL, .required = TRUE) %>%
        spq_filter(str_detect(labo_label, "EVS|(UMR 5600)|(Environnement Ville Soc)"))
    Output
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      SELECT ?labo (COALESCE(?labo_labell,'') AS ?labo_label) ?labo_id
      WHERE {
      
      OPTIONAL {
      	?labo dcterms:identifier ?labo_id.
      	
      ?labo skos:prefLabel ?labo_labell.
      }
      BIND(COALESCE(?labo_labell,'') AS ?labo_label)
      FILTER(REGEX(?labo_label,"EVS|(UMR 5600)|(Environnement Ville Soc)"))
      }
      

# spq_label() for optional thing

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_add("?loc wdt:P625 ?coords") %>% spq_add(
        "?film wdt:P3383 ?image") %>% spq_add("?film wdt:P921 ?subject", .required = FALSE) %>%
        spq_add("?film wdt:P577 ?date") %>% spq_label(film, loc, subject) %>%
        spq_head(10)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?coords ?date ?film (COALESCE(?film_labell,'') AS ?film_label) ?image ?loc (COALESCE(?loc_labell,'') AS ?loc_label) ?subject (COALESCE(?subject_labell,'') AS ?subject_label)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      ?loc wdt:P625 ?coords.
      ?film wdt:P3383 ?image.
      OPTIONAL {
      	?film wdt:P921 ?subject.
      	
      OPTIONAL {
      	?subject rdfs:label ?subject_labell.
      	FILTER(lang(?subject_labell) IN ('en'))
      }
      
      }
      ?film wdt:P577 ?date.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      OPTIONAL {
      	?loc rdfs:label ?loc_labell.
      	FILTER(lang(?loc_labell) IN ('en'))
      }
      
      
      }
      
      LIMIT 10

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_add("?loc wdt:P625 ?coords") %>% spq_add(
        "?film wdt:P3383 ?image") %>% spq_add("?film wdt:P921 ?subject", .required = FALSE) %>%
        spq_add("?film wdt:P577 ?date") %>% spq_label(film, loc, subject, .required = TRUE) %>%
        spq_head(10)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?coords ?date ?film (COALESCE(?film_labell,'') AS ?film_label) ?image ?loc (COALESCE(?loc_labell,'') AS ?loc_label) ?subject (COALESCE(?subject_labell,'') AS ?subject_label)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      ?loc wdt:P625 ?coords.
      ?film wdt:P3383 ?image.
      OPTIONAL {
      	?film wdt:P921 ?subject.
      	
      
      	?subject rdfs:label ?subject_labell.
      	FILTER(lang(?subject_labell) IN ('en'))
      
      }
      ?film wdt:P577 ?date.
      
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      
      
      	?loc rdfs:label ?loc_labell.
      	FILTER(lang(?loc_labell) IN ('en'))
      
      
      }
      
      LIMIT 10

