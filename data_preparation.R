library(readxl)
library(dplyr)



microdata <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Data', na = "NA", skip = 1)

microdata$date <- as.Date(microdata$date, origin = "1900-01-01", format = "%Y%m") 

column.key <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Codebook', skip = 1)

column.key <- cbind(column.key$Question, column.key$Description)

#View(column.key)