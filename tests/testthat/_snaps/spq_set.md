# spq_set() works

    Code
      spq_init() %>% spq_set(species = c("wd:Q144", "wd:Q146", "wd:Q780"), mayorcode = "wd:Q30185")
    Output
      
      SELECT *
      WHERE {
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      VALUES ?mayorcode {wd:Q30185}
      
      }
      

# spq_set() works with URLs

    Code
      spq_init() %>% spq_set(species = c("https://www.wikidata.org/entity/Q144",
        "https://www.wikidata.org/entity/Q146",
        "https://www.wikidata.org/entity/Q780"), mayorcode = "wd:Q30185")
    Output
      
      SELECT *
      WHERE {
      VALUES ?species {wd:Q144 wd:Q146 wd:Q780}
      VALUES ?mayorcode {wd:Q30185}
      
      }
      

# spq_set() in two examples

    Code
      spq_init() %>% spq_prefix(prefixes = c(schema = "http://schema.org/")) %>%
        spq_set(lemma = c("'Wikipedia'@de", "'Wikidata'@de", "'Berlin'@de",
          "'Technische Universität Berlin'@de")) %>% spq_add(
        "?sitelink schema:about ?item") %>% spq_add(
        "?sitelink schema:isPartOf <https://de.wikipedia.org/>") %>% spq_add(
        "?sitelink schema:name ?lemma") %>% spq_select(lemma, item)
    Output
      PREFIX schema: <http://schema.org/>
      SELECT ?item ?lemma
      WHERE {
      
      ?sitelink schema:about ?item.
      ?sitelink schema:isPartOf <https://de.wikipedia.org/>.
      ?sitelink schema:name ?lemma.
      VALUES ?lemma {'Wikipedia'@de 'Wikidata'@de 'Berlin'@de 'Technische Universität Berlin'@de}
      
      }
      

---

    Code
      spq_init() %>% spq_prefix(prefixes = c(schema = "http://schema.org/")) %>%
        spq_set(lemma = c("'Wikipedia'@de", "'Wikidata'@de", "'Berlin'@de",
          "'Technische Universität Berlin'@de")) %>% spq_mutate(item = schema::about(
        sitelink)) %>% spq_add(
        "?sitelink schema:isPartOf <https://de.wikipedia.org/>") %>% spq_mutate(
        lemma = schema::name(sitelink)) %>% spq_select(lemma, item)
    Output
      PREFIX schema: <http://schema.org/>
      SELECT ?item ?lemma
      WHERE {
      
      ?sitelink schema:about ?item.
      ?sitelink schema:isPartOf <https://de.wikipedia.org/>.
      ?sitelink schema:name ?lemma.
      VALUES ?lemma {'Wikipedia'@de 'Wikidata'@de 'Berlin'@de 'Technische Universität Berlin'@de}
      
      }
      

