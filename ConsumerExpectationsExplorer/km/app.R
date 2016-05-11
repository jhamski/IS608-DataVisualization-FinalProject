#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

runApp(list(
  ui = bootstrapPage(
    selectInput('dataset', 'Choose Dataset', c('mtcars', 'iris')),
    selectInput('columns', 'Columns', "")
  ),
  server = function(input, output, session){
    outVar = reactive({
      mydata = get(input$dataset)
      names(mydata)
    })
    observe({
      updateSelectInput(session, "columns",
                        choices = outVar()
      )})
  }
))

