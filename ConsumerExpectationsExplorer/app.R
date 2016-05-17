
library(shiny)
library(shinythemes) #https://rstudio.github.io/shinythemes/
library(ggplot2)
library(dplyr)

load("data_demo.Rda")
load("data_all.Rda")
load("survey_microdata.Rda")

source('project_theme.R')

# ----- UI ---------------------------------------------------> 

ui <- shinyUI(navbarPage("NYFRB Consumer Expectations Survey Explorer",
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
                                             choices = unique(colnames(microdata)), selected = "Rate of inflation / deflation over next 12 months"), 
                                 sliderInput("boundingPercentile", label = "Percentiles to display", min = 0, max =100, value = c(10, 90))),
                       column(8, plotOutput("distribution"), verbatimTextOutput("microSummary"))
                     ),
                     
                     fluidRow(
                       column(12, plotOutput("samplesPlot"))
                     )
                  ),
            
            tabPanel("Analysis", fluidPage(
              headerPanel("Statistical Analysis"),
              tabsetPanel(
                tabPanel("Seasonality"),
                tabPanel("Correlations")
              )
            )),
            
            tabPanel("More Information", fluidPage(
                       titlePanel("About the NYFRB Consumer Expectations Survey Explorer"),
                       includeMarkdown("information.md")
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
               
               if (is.null(input$demo))
                 return()
               
               color.1 = input$Question
               color.2 = input$demo

               ggplot() + 
                 #the temporary aesthetics error is because of the color assignment in the next line
                 geom_line(data =  filter(data.all, Question == input$Question & survey == input$metric), aes(x = date, y = results, color = color.1)) + 
                 geom_line(data =  filter(data.demo, Question == input$question & Demographic == input$demo), 
                           aes(x = date, y = results, color = color.2)) + 
                 scale_color_manual(values = c("blue", "red"), guide = guide_legend(title = "")) +
                 scale_y_continuous(expand=c(0,0)) +
                 project.theme() + theme(legend.position = "bottom")
             })
             
             output$samplesPlot <- renderPlot({
               ggplot(microdata %>%
                        filter(!is.na(input$Microdata_Question)) %>%
                        select(`Month Survey was administered`) %>%
                        group_by(`Month Survey was administered`) %>%
                        count(`Month Survey was administered`)) + 
                 geom_bar(aes(x = `Month Survey was administered`, y = n), stat = "identity") + project.theme()
               
             })
             
             output$distribution <- renderPlot({
              #Idea - let the user select the quantiles to display, but default to 10 / 90
               lower <- input$boundingPercentile[1] / 100
               upper <- input$boundingPercentile[2] / 100
               
               if(typeof(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))[[1]]) == "double"){
                 q = quantile(as.matrix(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))), na.rm = TRUE, probs =  c(lower, upper))
               } 
               
               ifelse(
                 typeof(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))[[1]]) == "double", 
                      return(ggplot(microdata, aes_string(x = paste("`",input$Microdata_Question, "`", sep=""))) + geom_density(na.rm = TRUE) + xlim(q[1], q[2])+ project.theme()), 
                      return(ggplot(microdata) + geom_bar(aes_string(x = paste("`",input$Microdata_Question, "`", sep="")), stat = "count") + project.theme()) 
               )
             })
             
             output$microSummary <- renderPrint(summary(select_(microdata, paste("`",input$Microdata_Question, "`", sep=""))))
})

# Run the application 
shinyApp(ui = ui, server = server)

