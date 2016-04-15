library(readxl)
library(dplyr)

microdata <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Data')
column.key <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Codebook')

