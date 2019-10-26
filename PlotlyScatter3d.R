library(plotly)
library(RGB)

set.seed(2019-10-25)

x <- rep(seq(0, 10, 0.1),10)
y <- sapply(seq(0, 10, 0.1), function(x) rep(x,10))
y <- as.vector(y)
z <- sin(x-y)

plot_ly(x = ~x, y = ~y, z = ~z, type = "scatter3d", color = ~z, 
        opacity = 0.5, mode = "lines+markers+text", name = "Cool trigonometry")

            