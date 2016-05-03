library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(zoo)

microdata <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Data', na = "NA", skip = 1)
colnames(microdata)[189] <- "_HH_INC_CAT2"

#column.key <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Codebook', skip = 1)

#column.key <- cbind(column.key$Question, column.key$Description)

#View(column.key)


#############################
# Data prep for Final Project
#############################

microdata <- microdata[!is.na(microdata$date),]
microdata$date <- as.character(microdata$date)

microdata$date <- as.Date(as.yearmon(microdata$date, "%Y%m"), frac= 1) 

education.levels <- c("Less than high school",
                      "High school dipoma/equivalent",
                      "Some college but no degree",
                      "Associates/ JC College degree",
                      "Bachelor's Degree",
                      "Master's Degree",
                      "Doctoral Degree",
                      "Professional Degree",
                      "Other education")

microdata$Q36 <- factor(microdata$Q36, levels = 1:9, labels = education.levels)

better.worse <- c("much worse off",
                 "somewhat worse off",
                 "about the same",
                 "somewhat better off",
                 "much better off")

microdata$Q1 <- factor(microdata$Q1, levels = 1:5, labels = better.worse)
microdata$Q2 <- factor(microdata$Q2, levels = 1:5, labels = better.worse)


############################
# Data prep for d3 assignment
############################

microdata$year <- format(microdata$date, format = "%m")
#state doesn't make sense, do something else
d3.dataset <- microdata %>%
  select(Q36, `_STATE`, Q25v2part2, year) %>%
  filter(Q25v2part2 < 100) %>%
  filter(Q25v2part2 > - 100) %>%
  na.omit() %>%
  group_by(year, `_STATE`) %>%
  summarize(mean(Q25v2part2))
  

colnames(d3.dataset) <- c("education", "mean_income_expectation")

ggplot(data = d3.dataset, aes(education, mean_income_expectation)) + geom_bar(stat="identity")

write_delim(d3.dataset, path = 'consumer_expectations.csv', delim = ',')

####################################
# Data prep for d3 assignment part 2
####################################

d3.dataset.2 <- microdata %>%
  select(date, Q25v2part2, Q26v2part2) %>%
  filter(Q25v2part2 < 100) %>%
  filter(Q25v2part2 > - 100) 

d3.dataset.2$month <- format(d3.dataset.2$date, format="%m")
d3.dataset.2$year <- format(d3.dataset.2$date, format="%y")
d3.dataset.2 <-  aggregate(Q25v2part2 ~ month + year, d3.dataset.2, mean)

write_delim(d3.dataset.2, path = 'consumer_expectations_2.csv', delim = ',')
