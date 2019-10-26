library(shiny)
library(leaflet)
library(XML)
library(dplyr)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


server <- function(input, output, session) {
    # Get data from https://opendata-ajuntament.barcelona.cat/data/es/dataset/punts-informacio-turistica
    fileUrl = "http://www.bcn.cat/tercerlloc/pits_opendata_en.xml"
    xmlFileName = "./pits_opendata_en.xml"
    
    if(!file.exists(xmlFileName)) {
        download.file(fileUrl, destfile = xmlFileName)
    }
    
    doc <- xmlTreeParse(xmlFileName, useInternalNodes = TRUE, encoding="UTF-8")
    xmlRootName <- xmlRoot(doc)
    
    names_array <- latitude <- longitude <- district <- descr <- NULL
    sapply(xpathSApply(xmlRootName, "/opendata/list_items/row"), 
           function(x) {
               names_array <<- c(names_array, xpathSApply(x, "name/text()", xmlValue))
               latitude    <<- c(latitude,  xpathSApply(x, "gmapx/text()", xmlValue))
               longitude   <<- c(longitude, xpathSApply(x, "gmapy/text()", xmlValue))
               distr       <- xpathSApply(x, "district/text()", xmlValue)
               district    <<- c(district, ifelse(is.null(distr), "",  distr))
               descr       <<- c(descr, xpathSApply(x, "content/text()", xmlValue))
               NULL
           }
    )
    
    latitude  <- sapply(latitude, as.numeric)
    longitude <- sapply(longitude, as.numeric)
    
    df <- data.frame(latitude = latitude, longitude = longitude, 
                     district = district, names = names_array, description = descr)
    df1 <- NULL
    
    output$mymap <- renderLeaflet({
        selectedDistrict <- NULL
        if(input$SantsMontjuic) {selectedDistrict <- c(selectedDistrict, "Sants-Montjuïc")}
        if(input$SantMarti)     {selectedDistrict <- c(selectedDistrict, "Sant Martí")}
        if(input$NouBarris)     {selectedDistrict <- c(selectedDistrict, "Nou Barris")}
        if(input$Eixample)      {selectedDistrict <- c(selectedDistrict, "Eixample")}
        if(input$Sarria)        {selectedDistrict <- c(selectedDistrict, "Sarrià-Sant Gervasi")}
        if(input$LesCorts)      {selectedDistrict <- c(selectedDistrict, "Les Corts")}
        if(input$CiutatVella)   {selectedDistrict <- c(selectedDistrict, "Ciutat Vella")}
        if(input$HortaGuinardo) {selectedDistrict <- c(selectedDistrict, "Horta-Guinardó")}
        if(input$Gracia)        {selectedDistrict <- c(selectedDistrict, "Gràcia")}
        if(input$SantAndreu)    {selectedDistrict <- c(selectedDistrict, "Sant Andreu")}
        
#        selectedDistrict <- "Sant Martí"
        output$text <- renderText(selectedDistrict)
        
        df1 <<- df %>% filter(district %in% selectedDistrict)
        df1 %>%
            leaflet() %>%
            addTiles() %>%
            addMarkers(popup = df1$names, clusterOptions = markerClusterOptions(), 
                       layerId =1:nrow(df1))
    })
    
    observe({
        click<-input$mymap_marker_click
        if(is.null(click))
            return()
        text<-paste("Latitude ", click$lat, "Longitude ", click$lng, "id ", click$id, 
                    "nrow", nrow(df1), "names", df1$description[click$id])
        text2<-paste("You've selected point ", click$lat)
        output$text<-renderText({text})
    })
}

