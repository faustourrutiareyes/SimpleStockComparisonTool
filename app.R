#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(plotly)
library(tidyverse)
library(tidyquant)

stock_names <- read.csv("NASDAQ_Stock_generalList.csv")
stock_names$Symbol <- stock_names$Symbol %>% str_replace_all("[/^]", "-")

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Stock Comparison Tool"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectizeInput("tickers", paste("Stocks to Compare:"),
        choices = NULL,
        options = list(placeholder = "Select Stocks as Ticker Name (e.g. AMZN, MSFT, NFLX,...)"),
        multiple = TRUE
      ),
      dateRangeInput("dates",
        "Date range:",
        start = "2013-01-01",
        end = as.character(Sys.Date()),
        max = Sys.Date(),
        format = "yyyy-mm-dd",
        startview = "decade",
        language = "en"
      ),
      h5("Use the button on the upper-corner of the plot to view several tickers' data on hover")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("distPlot"),
      dataTableOutput("stockTable")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  updateSelectizeInput(session, "tickers", choices = unique(stock_names$Symbol), server = TRUE)

  download_prices <- reactive({
    if (length(input$tickers) == 0) {
      prices <- tq_get(c("AAPL", "MSFT"),
        from = input$dates[1],
        to = input$dates[2],
        get = "stock.prices"
      )
    } else {
      prices <- tq_get(input$tickers,
        from = input$dates[1],
        to = input$dates[2],
        get = "stock.prices"
      )
    }
  })

  prices <- reactive({
    prices <- download_prices()

    prices <- group_by(prices, symbol)

    prices <- mutate(prices, index = adjusted / adjusted[1])
    prices <- mutate(prices, relative_index = index - 1)

    prices <- merge(prices, stock_names[, c("Symbol", "Name")], by.x = "symbol", by.y = "Symbol", all.x = T)
  })

  output$distPlot <- renderPlotly({
    ggplotly(ggplot() +
      geom_line(data = prices(), aes(x = date, y = round(relative_index, digits = 3), color = Name), size = 1.01) +
      geom_hline(yintercept = 0) +
      labs(title = "Stock Comparison Tool", y = "Relative Change from Starting Date", x = "Date") +
      theme_minimal())
  })

  output$stockTable <- renderDataTable({
    prices <- as.data.frame(prices())

    InitialValues <- prices %>%
      group_by(prices$symbol) %>%
      filter(row_number() == 1) %>%
      rename(initialValue = adjusted)
    LastValues <- prices %>%
      filter(date == max(date)) %>%
      rename(finalValue = adjusted)

    initial_last_values <- as.data.frame(InitialValues) %>%
      left_join(LastValues[, c("symbol", "finalValue", "relative_index")], by = "symbol") %>%
      rename(finalIndex = relative_index.y) %>%
      mutate(changeByPercentage = paste(round(finalIndex, 2), "%"))

    initial_last_values <- initial_last_values[, c(
      "symbol",
      "Name",
      "initialValue",
      "finalValue",
      "changeByPercentage"
    )]

    # LastValues
    initial_last_values
  })
}

# Run the application
shinyApp(ui = ui, server = server)
