setwd("~/Projects")  # Change this to parent folder of code
library(ggplot2)
library(shiny)

HOURS_IN_WEEK <- 168

server <- function(input, output) {
    # Gives df1 and dfts

    df1 <- read.csv(file = "/tmp/delme.csv", header = TRUE)
    names(df1) <- c("","WT1","WT2")
    df_ts <- read.csv(file = "./ArchConfRML/data/weekly/delme.csv", header = FALSE)
    df2 <- reactiveValues(
      KWH=t(df_ts[1,])
    )
    Hour <- 1:HOURS_IN_WEEK  
    
    df1$siteid <- 1:nrow(df1)    # Site id's
    output$distPlot <- renderPlot({
      ggplot(df1,aes(x=WT1,y=WT2)) + geom_point()
    })
    output$distPlot2 <- renderPlot({
      qplot(Hour, df2$KWH,ylab = "kWH")
    })
  
    observeEvent(input$plot_click, {
      x<-nearPoints(df1, input$plot_click, maxpoints = 1)
      if(nrow(x) > 0) {
        df2$KWH <- t(df_ts[x$siteid,])
      }
    })
}

ui <- fluidPage(
  title = "Autoencoder",
  fluidRow(
    column(width = 4,
           plotOutput("distPlot",click="plot_click")
    ),
    column(width = 3, offset = 2,
           plotOutput("distPlot2")
    )
  )
)

shinyApp(ui = ui, server = server)