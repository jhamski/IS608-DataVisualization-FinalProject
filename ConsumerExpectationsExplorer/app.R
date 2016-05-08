
library(shiny)
library(ggplot2)

load("data_demo.Rda")
load("data_all.Rda")


# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("NYFRB Consumer Expectations Survey"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("survey", label = h5("Survey Question"), 
                    choices = choices.1),
        selectInput("question", label = h5("Survey Question for Demographic Slice"), 
                    choices = unique(data.demo$Question)),
        selectInput("demo", label = h5("Demographic Slice"), 
                    choices = unique(data.demo$Demographic))
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
       geom_line(data =  filter(data.all, survey == input$survey), aes(x = date, y = results, color = input$survey)) + 
       geom_line(data =  filter(data.demo, Question == input$question & Demographic == input$demo), 
                 aes(x = date, y = results, color = as.character(input$demo))) + 
       scale_color_manual(values = c("blue", "red"), guide = guide_legend(title = "Timeseries Displayed")) + 
       theme(legend.position = "bottom")
   })
})

# Run the application 
shinyApp(ui = ui, server = server)

