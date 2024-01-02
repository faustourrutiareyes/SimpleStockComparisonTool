library(tidyquant)
library(tidyverse)

tickers <- c("AMZN", "GOOGL", "KO")

prices <- tq_get(tickers,
                 from = "2017-01-04",
                 to = "2023-12-29",
                 get = "stock.prices")

prices <- group_by(prices, symbol)

prices <- mutate(prices, index = adjusted / adjusted[1])
prices <- mutate(prices, index_zero = index - 1)

ggplot()+
  geom_line(data = prices, aes(x= date, y = index_zero, color = symbol), size = 1.01)+
  geom_hline(yintercept = 0)+
  labs(title = "Stock Comparison Tool", y = "Relative Change from Starting Date", x = "Date")+
  theme_minimal()

