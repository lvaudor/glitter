usual_prefixes=rbind(
  tibble(name="foaf",
         url="http://xmlns.com/foaf/0.1/"),
  tibble(name="rdfs",
         url="http://www.w3.org/2000/01/rdf-schema"),
  tibble(name="bio",
         url="http://vocab.org/bio/0.1/"),
  tibble(name="dcterms",
         url="http://purl.org/dc/terms/"),
  tibble(name="xsd",
         url="http://www.w3.org/2001/XMLSchema#"),
  tibble(name="isni",
         url="http://isni.org/ontology#"),
  tibble(name="rdarelationships",
         url="http://rdvocab.info/RDARelationshipsWEMI/")
)
usethis::use_data(usual_prefixes,overwrite=TRUE)

# ogc:  http://www.opengis.net/
#   geo:  http://www.opengis.net/ont/geosparql#
# geof: http://www.opengis.net/def/function/geosparql/
#   geor: http://www.opengis.net/def/rule/geosparql/
#   sf:  http://www.opengis.net/ont/sf#
# gml: http://www.opengis.net/ont/gml#
# my:  http://example.org/ApplicationSchema#
# xsd:  http://www.w3.org/2001/XMLSchema#
# rdf:   http://www.w3.org/1999/02/22-rdf-syntax-ns#
# rdfs: http://www.w3.org/2000/01/rdf-schema#
# owl:  http://www.w3.org/2002/07/owl#

