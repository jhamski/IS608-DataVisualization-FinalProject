
library(shiny)
library(ggplot2)

load("data_demo.Rda")
load("data_all.Rda")

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("survey", label = h3("Select Survey Question"), 
                    choices = list(unique(data.all$survey))),
        selectInput("question", label = h3("Select Survey Question for Demographic Slice"), 
                    choices = list(unique(data.demo$Question))),
        selectInput("demo", label = h3("Select Demographic"), 
                    choices = list(unique(data.demo$Demographic)))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
   
   output$distPlot <- renderPlot({
     ggplot() + 
       geom_line(data =  filter(data.all, survey == input$survey), aes(x = date, y = results)) + 
       geom_line(data =  filter(data.demo, Question == input$question & Demographic == input$demo), aes(x = date, y = results))
   })
})

# Run the application 
shinyApp(ui = ui, server = server)

