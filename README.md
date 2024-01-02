# Simple Stock Comparison Tool

This tool allows for easy viewing of multiple NASDAQ listed stock tickers' performance. To use the tool R is needed.

To use the tool the following paramaters need to be changed: List of tickers, starting date, and end date.

For example to get the relative performance of Amazon, Google, Coca-Cola and Tesla stock from January 4, 2017 to December 29, 2023 the following snippet needs to look like the following:

tickers <- c("AMZN", "GOOGL", "KO", "TSLA")

prices <- tq_get(tickers,
                 from = "2017-01-04", 
                 to = "2023-12-29",
                 get = "stock.prices")

The above produces the following output:
![image](https://github.com/faustourrutiareyes/SimpleStockComparisonTool/assets/41218224/4049bc59-49f0-4770-b87b-75af56766ef7)

