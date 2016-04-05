library(ggplot2)
library(shiny)

hiddenWtDf <-
  data.frame(X.hiddenValues) #<- read.csv(file = "/tmp/delme.csv", header = TRUE)
#allTrainingTS <- read.csv(file = "~/ArchConfRML/data/weekly/delme.csv", header = FALSE)
allTrainingTS <- data.frame(weekly.Training.Data)
names(hiddenWtDf) <- c("ft1", "ft2") # Needed for axes label
hiddenWtDf$siteid <-
  1:nrow(hiddenWtDf)    # add a site ID # Site id's

HOURS_IN_WEEK <- 168
Hour <- 1:HOURS_IN_WEEK
selectedTS <- reactiveValues(KWH = t(allTrainingTS[1, ]))

server <- function(input, output) {
  # Gives hiddenWtDf and allTrainingTS
  output$lhsPlot <- renderPlot({
    ggplot(hiddenWtDf, aes(x = ft1, y = ft2)) + geom_point()
  })
  output$rhsPlot <- renderPlot({
    qplot(
      Hour,
      selectedTS$KWH,
      ylab = "kWH",
      xlab = "hr of wk",
      geom = "line"
    )
  })

  observeEvent(input$plot_click, {
    x <-
      nearPoints(hiddenWtDf[c("siteid", "ft1", "ft2")], input$plot_click, maxpoints = 1)
    if (nrow(x) > 0) {
      selectedTS$KWH <- t(allTrainingTS[x$siteid, ])
    }
  })
}


ui <- fluidPage(#Page layout:
  title = "Autoencoder",
  fluidRow(
    column(width = 4,
           plotOutput("lhsPlot", click = "plot_click")),
    column(width = 3, offset = 2,
           plotOutput("rhsPlot"))
  ))

shinyApp(ui = ui, server = server)
