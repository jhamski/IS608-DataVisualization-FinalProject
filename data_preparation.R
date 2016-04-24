library(readxl)
library(readr)
library(dplyr)
library(ggplot2)



microdata <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Data', na = "NA", skip = 1)
colnames(microdata)[189] <- "_HH_INC_CAT2"

microdata$date <- as.Date(microdata$date, origin = "1900-01-01", format = "%Y%m") 

column.key <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Codebook', skip = 1)

column.key <- cbind(column.key$Question, column.key$Description)

#View(column.key)


############################
# Data prep for d3 assignment
############################

set.seed(56498)

d3.dataset <- microdata %>%
  select(Q32, Q36, Q23v2, Q23v2part2, Q14new) %>%
  na.omit() %>%
  filter(Q23v2 %in% c(1,2)) %>%
  select(Q32, Q36, Q23v2part2, Q14new) %>%
  filter(Q32 < 100) %>%
  filter(Q23v2part2 < 50) %>%
  filter(Q36 %in% c(5,6)) %>%
  group_by(Q36) %>%
  sample_n(100)

colnames(d3.dataset) <- c("age", "education", "income_expectation","chance_leave_job")

education.levels <- c("Less than high school",
                      "High school dipoma/equivalent",
                      "Some college but no degree",
                      "Associates/ JC College degree",
                      "Bachelor's Degree",
                      "Master's Degree",
                      "Doctoral Degree",
                      "Professional Degree",
                      "Other education")

d3.dataset$education <- factor(d3.dataset$education, levels = 1:9, labels = education.levels)

ggplot(data = d3.dataset, aes(age, income_expectation, size = chance_leave_job)) + geom_point(aes(color=factor(education)))

write_delim(d3.dataset, path = 'consumer_expectations.csv', delim = ',')
