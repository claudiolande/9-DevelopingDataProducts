# This is the user-interface definition of a Shiny web application.
library(shiny)
library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

shinyUI(fluidPage(
    titlePanel("Barcelona tourist sites"),
    sidebarLayout(
        sidebarPanel(
            h4("Select areas"),
            checkboxInput("SantsMontjuic", "Sants-Montjuïc", value = TRUE),
            checkboxInput("SantMarti", "Sant Martí", value = TRUE),
            checkboxInput("NouBarris", "Nou Barris", value = TRUE),
            checkboxInput("Eixample", "Eixample", value = TRUE),
            checkboxInput("Sarria", "Sarrià-Sant Gervasi", value = TRUE),
            checkboxInput("LesCorts", "Les Corts", value = TRUE),
            checkboxInput("CiutatVella", "Ciutat Vella", value = TRUE),
            checkboxInput("HortaGuinardo", "Horta-Guinardó", value = TRUE),
            checkboxInput("Gracia", "Gràcia", value = TRUE),
            checkboxInput("SantAndreu", "Sant Andreu", value = TRUE)
        ),
        mainPanel(
            tabsetPanel(type = "tabs", 
                tabPanel("Instructions", br(), h1("Instructions"), "This app..."), 
                tabPanel("Barcelona tourist sites", 
                         leafletOutput("mymap"),
                         textOutput("text")
                )
            )
        )
    )
))
