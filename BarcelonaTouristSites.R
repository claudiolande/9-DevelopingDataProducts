library(XML)
library(dplyr)
library(leaflet)

# Get data from https://opendata-ajuntament.barcelona.cat/data/es/dataset/punts-informacio-turistica
fileUrl = "http://www.bcn.cat/tercerlloc/pits_opendata_en.xml"
xmlFileName = "./pits_opendata_en.xml"

if(!file.exists(xmlFileName)) {
    download.file(fileUrl, destfile = xmlFileName)
}

doc <- xmlTreeParse(xmlFileName, useInternalNodes = TRUE)
xmlRootName <- xmlRoot(doc)

sitesName      <- xpathSApply(xmlRootName, "/opendata/list_items/row/name", xmlValue)
#sitesURL       <- xpathSApply(xmlRootName, "/opendata/list_items/row/interestinfo/item[last()]/interinfo", xmlValue)
sitesLatitude  <- xpathSApply(xmlRootName, "/opendata/list_items/row/gmapx/text()", xmlValue)
sitesLongitude <- xpathSApply(xmlRootName, "/opendata/list_items/row/gmapy/text()", xmlValue)


sitesLatitude  <- sapply(sitesLatitude, as.numeric)
sitesLongitude <- sapply(sitesLongitude, as.numeric)


df <- data.frame(lat = sitesLatitude, lng = sitesLongitude)

df %>%
    leaflet() %>%
    addTiles() %>%
    addMarkers(popup = sitesName, clusterOptions = markerClusterOptions())
