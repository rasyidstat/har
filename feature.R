library(tidyverse)
library(data.table)

# read data
har_raw <- fread("data/selected_body_part.csv")
har_raw <- as.matrix(har_raw)

# use square root x^2 + y^2 + z^2
rsse <- function(x, y, z) {
  sqrt(x^2 + y^2 + z^2)
}

for (i in 1:((ncol(har_raw)-1)/3) ) {
  r <- i * 3 - 2
  har_reduced[,i] <- rsse(har_raw[,r], har_raw[,r+1], har_raw[,r+2])
}

# features extraction using window size = 2s (60 data), sliding window = 1s (30 data)
# just use basic stats summary -> min, max, std, median
window <- 60
slide <- 30




