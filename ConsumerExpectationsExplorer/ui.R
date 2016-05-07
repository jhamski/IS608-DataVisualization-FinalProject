#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)


load("project_data.Rda")

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("cosmo"),
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("select", label = h3("Select box"), 
                  choices = list("Financially better or worse off than 12 months ago" = "Fin.better.worse.ago.1",
                                 "Financially better or worse off 12 months from now" = "Fin.better.worse.from.now.2"),
                  )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("distPlot")
    )
  )
))
