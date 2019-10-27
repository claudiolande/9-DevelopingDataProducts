library(shiny)
library(leaflet)

shinyUI(fluidPage(
    titlePanel("Interactive Barcelona tourist map"),
    sidebarLayout(
        sidebarPanel(
            h4("Select districts"),
            checkboxInput("SantsMontjuic", "Sants-Montjuïc", value = TRUE),
            checkboxInput("SantMarti", "Sant Martí", value = TRUE),
            checkboxInput("NouBarris", "Nou Barris", value = TRUE),
            checkboxInput("Eixample", "Eixample", value = TRUE),
            checkboxInput("Sarria", "Sarrià-Sant Gervasi", value = TRUE),
            checkboxInput("LesCorts", "Les Corts", value = TRUE),
            checkboxInput("CiutatVella", "Ciutat Vella", value = TRUE),
            checkboxInput("HortaGuinardo", "Horta-Guinardó", value = TRUE),
            checkboxInput("Gracia", "Gràcia", value = TRUE),
            checkboxInput("SantAndreu", "Sant Andreu", value = TRUE),
            h4("Search"),
            textInput("searchString", label = NULL),
            textOutput("nresults"),
            width = 3
        ),
        mainPanel(
            tabsetPanel(type = "tabs", 
                tabPanel("Barcelona tourist sites", 
                         leafletOutput("mymap"),
                         h1(textOutput("sitename")),
                         htmlOutput("siteurl"),
                         htmlOutput("text")
                ),
                tabPanel("Instructions", br(), 
                     h1("Instructions"), 
                     p("This app is designed as a convenient tool for tourists willing to visit Barcelona as it allows to easily locate the most important tourist sites on the city map."),
                     p("Usage is straightforward:"),
                     p("- you can restrict the search to any number of city districts by selecting them on the left panel"),
                     p("- you can search the sites by name. The sites whose name matches the text will be shown on the map as you type."),
                     p("- if you click on a pin"),
                     p("-- the corresponding site name will be displayed on top of the pin"),
                     p("-- the corresponding site name, URL and description will be displayed on the page bottom."),
                     p("For more information about the application, please see:"),
                     a("http://rpubs.com/claudiolande/InteractiveBarcelonaTouristMap", 
                       href = "http://rpubs.com/claudiolande/InteractiveBarcelonaTouristMap")
                ) 
            )
        )
    )
))
