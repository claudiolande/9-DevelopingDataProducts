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
    
    names_array <- latitude <- longitude <- district <- descr <- url <- NULL
    sapply(xpathSApply(xmlRootName, "/opendata/list_items/row"), 
           function(x) {
               names_array <<- c(names_array, xpathSApply(x, "name/text()", xmlValue))
               latitude    <<- c(latitude,  xpathSApply(x, "gmapx/text()", xmlValue))
               longitude   <<- c(longitude, xpathSApply(x, "gmapy/text()", xmlValue))
               distr       <- xpathSApply(x, "district/text()", xmlValue)
               district    <<- c(district, ifelse(is.null(distr), "",  distr))
               descr       <<- c(descr, xpathSApply(x, "content/text()", xmlValue))
               itemUrl     <- xpathSApply(x, "code_url/text()", xmlValue)
               url         <<- c(url, ifelse(is.null(itemUrl), "",  itemUrl))
               NULL
           }
    )
    
    latitude  <- sapply(latitude, as.numeric)
    longitude <- sapply(longitude, as.numeric)
    
    df <- data.frame(latitude = latitude, longitude = longitude, district = district, 
                     names = names_array, description = descr, siteurl = url)
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
        
        #output$text <- renderText(selectedDistrict)
        
        # filter sites using the district
        df1 <<- df %>% filter(district %in% selectedDistrict)
        
        # filter sites using the search string
        s <- paste("*", input$searchString, ".*", sep = "")
        df1 <<- df1[grepl(s, df1$names, ignore.case = TRUE), ]
        
        output$nresults<-renderText({paste ("Found", nrow(df1), "sites")})
        
        # draw the map  
        df1 %>%
            leaflet() %>%
            addTiles() %>%
            addMarkers(popup = df1$names, clusterOptions = markerClusterOptions(), 
                       layerId = 1:nrow(df1))
    })
    
    observe({
        click<-input$mymap_marker_click
        if(is.null(click))
            return()
        output$sitename  <- renderText({paste(df1$names[click$id])})
        output$latitude  <- renderText({paste("Latitude", click$lat)})
        output$longitude <- renderText({paste("Longitude", click$lng)})
        output$text      <- renderText({paste(df1$description[click$id])})
        output$siteurl   <- renderText({paste("URL: <a href=", df1$siteurl[click$id],
                                              ">", df1$siteurl[click$id], "</a>", sep = "")})
    })
}

