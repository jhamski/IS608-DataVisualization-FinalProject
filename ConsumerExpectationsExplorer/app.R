
library(shiny)
library(shinythemes) #https://rstudio.github.io/shinythemes/
library(ggplot2)
library(dplyr)

load("data_demo.Rda")
load("data_all.Rda")

# ----- UI ---------------------------------------------------> 

ui <- shinyUI(navbarPage("NYFRB Consumer Expectations Survey",
            tabPanel("Timeseries View", fluidPage(theme = shinytheme("Flatly"),
   
                     # Page title
                     titlePanel("NYFRB Consumer Expectations Survey"),
                     
                     sidebarLayout(
                        sidebarPanel(
                          selectInput("Question", label = h5("Survey Question - All Respondents"), 
                                      choices = unique(data.all$Question)),
                          
                          selectInput('metric', 'Metric', ""),
                          
                          selectInput("question", label = h5("Survey Question for Demographic Slice"), 
                                      choices = unique(data.demo$Question)),
                          selectInput("demo", label = h5("Demographic Slice"), 
                                      choices = unique(data.demo$Demographic))
                        ),
                        
                        # Demo plot
                        mainPanel(
                           plotOutput("demoPlot")
                        )
                      )
                    )
                  ),
            
            tabPanel("Microdata"
                     
                  ),
            
            tabPanel("More Information", fluidPage(
                       titlePanel("test")
                      )
                     )
            
  )
)

# ----- Server ---------------------------------------------------> 

server <- shinyServer(function(input, output, session) {
            outVar = reactive({
              mydata = unique(filter(data.all, Question == input$Question))
              return(mydata$survey)
            })
            
            observe({
              updateSelectInput(session, "metric",
                                choices = outVar()
            )})
               
             output$demoPlot <- renderPlot({
               ggplot() + 
                 geom_line(data =  filter(data.all, Question == input$Question & survey == input$metric), aes(x = date, y = results, color = input$Question)) + 
                 geom_line(data =  filter(data.demo, Question == input$question & Demographic == input$demo), 
                           aes(x = date, y = results, color = as.character(input$demo))) + 
                 scale_color_manual(values = c("blue", "red"), guide = guide_legend(title = "")) + 
                 theme(legend.position = "bottom")
             })
})

# Run the application 
shinyApp(ui = ui, server = server)

