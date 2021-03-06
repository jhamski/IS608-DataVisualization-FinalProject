# Final Project: IS608 - Data Visualization

require(shiny)
require(shinythemes) #https://rstudio.github.io/shinythemes/
require(ggplot2)
require(dplyr)
require(markdown)
require(devtools)
require(tidyr)
require(DT)

is.installed <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
} 

if (!is.installed("ggbiplot")){
  install_github("vqv/ggbiplot")
}

require(ggbiplot)

load("data_demo.Rda")
load("data_all.Rda")
load("survey_microdata.Rda")


source('project_theme.R')

# ----- UI ---------------------------------------------------> 

ui <- shinyUI(navbarPage("FRBNY Consumer Expectations Survey Explorer",
            tabPanel("Project Information", fluidPage(
               includeMarkdown("information.md"))), 
            tabPanel("Timeseries", fluidPage(theme = shinytheme("flatly"),
                     titlePanel("FRBNY Consumer Expectations Survey - Calculated Timeseries"),
                     
                     sidebarLayout(
                        sidebarPanel(
                          selectInput("Question", label = h5("Survey Question - All Respondents"), 
                                      choices = unique(data.all$Question)),
                          
                          selectInput('metric', label = h5('Metric'), ""),
                          
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
                     titlePanel("Disribution of Survey Responses from the SCE Microdata"),
                     fluidRow(
                       column(4, selectInput("Microdata_Question", label = h5("Select Microdata Parameter"), 
                                             choices = unique(colnames(microdata)), selected = "Rate of inflation / deflation over next 12 months"), 
                                 sliderInput("boundingPercentile", label = "Percentiles to display", min = 0, max =100, value = c(10, 90))),
                       column(8, plotOutput("distribution"), verbatimTextOutput("microSummary"))
                     )
            ),
            
            tabPanel("Analysis", fluidPage(
              tabsetPanel(
                tabPanel("Seasonality",
                         sidebarPanel(
                           selectInput("Question2", label = h5("Survey Question - All Respondents"), 
                                       choices = unique(data.all$Question)),
                           
                           selectInput('metric2', 'Metric', "")
                         ),
                         mainPanel(
                           plotOutput("seasonal")
                         ), 
                         fluidRow(column(12, p("This page performs a seasonal decomposition on the selected timeseries using the", 
                                               a("Seasonal Decomposition of Time Series by Loess (stl)", href="https://stat.ethz.ch/R-manual/R-patched/library/stats/html/stl.html", target="_blank"), "function.")))
                         ),
                tabPanel("PCA",
                         fluidRow(column(6,
                           selectInput("question.PCA", label = h5("Select Timeseries"), 
                                       choices = unique(data.demo$Question))
                           ),
                           column(6, p("This section performs a Principle Component Analysis (PCA) on the selected timeseries 
                                       with demographic breakouts using the", a("prcomp", href="https://stat.ethz.ch/R-manual/R-devel/library/stats/html/prcomp.html", target="_blank"), "function."))),
                         fluidRow(column(12,
                           plotOutput("PCA")
                          )), 
                         fluidRow(column(12,
                                         DT::dataTableOutput('Rotations')
                         ))
                         )
              )
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
              
               
               color.1 = input$Question
               color.2 = input$demo

               ggplot() + 
                 #the temporary aesthetics error is because of the color assignment in the next line
                 geom_line(data =  filter(data.all, Question == input$Question & survey == input$metric), aes(x = date, y = results, color = input$metric)) + 
                 geom_line(data =  filter(data.demo, Question == input$question & Demographic == input$demo), 
                           aes(x = date, y = results, color = color.2)) + 
                 scale_color_discrete(guide = guide_legend(title = "")) +
                 scale_y_continuous(expand=c(0,0)) +
                 project.theme() + theme(legend.position = "bottom") + xlab("Month") + ylab("")
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
              
             outVar2 = reactive({
               mydata2 = unique(filter(data.all, Question == input$Question2))
               return(mydata2$survey)
             })
             
             observe({
               updateSelectInput(session, "metric2",
                                 choices = outVar2()
               )})
             
             
             output$seasonal <- renderPlot({
               seasonal.decom.data <- data.all %>%
                 filter(Question == input$Question2) %>%
                 filter(survey == input$metric2) %>%
                 select(results) 
               
               seasonal.decom.data <- ts(seasonal.decom.data$results, deltat = 1/12)
               
               plot(stl(seasonal.decom.data, s.window="periodic"))
               
             }) 
             
             PCA.dataset <- reactive({PCA.dataset <- data.demo %>%
               unite(col = Survey, Question, Demographic) %>%
               spread(key = Survey, value = results) %>% 
               select(-date) %>%
               select(matches(input$question.PCA)) %>% 
               as.matrix() %>%
               prcomp(tol = sqrt(.Machine$double.eps), scale = T)
               
               return(PCA.dataset)})
             
             output$PCA <- renderPlot({
               PCA.dataset <- PCA.dataset()
               ggbiplot(PCA.dataset, obs.scale = 1, var.scale = 1, circle = TRUE)
               
             })
             
             output$Rotations <- DT::renderDataTable({
               PCA.dataset <- PCA.dataset()
               PCA.dataset$rotation[,1:4]
             })
})

# Run the application 
shinyApp(ui = ui, server = server)

