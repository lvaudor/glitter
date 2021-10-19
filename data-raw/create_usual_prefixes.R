usual_prefixes=readr::read_csv("data-raw/usual_prefixes.csv")
usethis::use_data(usual_prefixes,overwrite=TRUE)

# ogc:  http://www.opengis.net/
#   geo:  http://www.opengis.net/ont/geosparql#
# geof: http://www.opengis.net/def/function/geosparql/
#   geor: http://www.opengis.net/def/rule/geosparql/
#   sf:  http://www.opengis.net/ont/sf#
# gml: http://www.opengis.net/ont/gml#
# my:  http://example.org/ApplicationSchema

