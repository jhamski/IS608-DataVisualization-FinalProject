
library(shiny)
library(shinythemes) #https://rstudio.github.io/shinythemes/
library(ggplot2)
library(dplyr)

load("data_demo.Rda")
load("data_all.Rda")
load("survey_microdata.Rda")

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
            
            tabPanel("Microdata",
                     fluidRow(
                       column(4, selectInput("Microdata_Question", label = h5("Select Microdata Parameter"), 
                                             choices = unique(colnames(microdata)), selected = "Rate of inflation / deflation over next 12 months")),
                       column(8, plotOutput("distribution"), verbatimTextOutput("microSummary"))
                     ),
                     
                     fluidRow(
                       column(12, plotOutput("samplesPlot"))
                     )
                  ),
            
            tabPanel("Analysis", fluidPage(
              titlePanel("test")
            )),
            
            tabPanel("More Information", fluidPage(
                       titlePanel("test")
            ))
                     
            
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
                 scale_color_manual(values = c("blue", "red"), guide = guide_legend(title = "")) + theme(legend.position = "bottom")
             })
             
             output$samplesPlot <- renderPlot({
               ggplot(microdata %>%
                        filter(!is.na(input$Microdata_Question)) %>%
                        select(`Month Survey was administered`) %>%
                        group_by(`Month Survey was administered`) %>%
                        count(`Month Survey was administered`)) + 
                 geom_bar(aes(x = `Month Survey was administered`, y = n), stat = "identity")
               
             })
             
             output$distribution <- renderPlot({
              #Idea - let the user select the quantiles to display, but default to 10 / 90
               q = quantile(as.matrix(select_(microdata, column.2)), na.rm = TRUE, probs =  c(0.1, 0.9))
               
               ifelse(
                 typeof(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))[[1]]) == "double", 
                      return(ggplot(microdata, aes_string(x = paste("`",input$Microdata_Question, "`", sep=""))) + geom_density(na.rm = TRUE) + xlim(q[1], q[2])), 
                      return(ggplot(microdata) + geom_bar(aes_string(x = paste("`",input$Microdata_Question, "`", sep="")), stat = "count")) 
               )
             })
             
             output$microSummary <- renderPrint(summary(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))))
})

# Run the application 
shinyApp(ui = ui, server = server)

