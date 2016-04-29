library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(zoo)

microdata <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Data', na = "NA", skip = 1)
colnames(microdata)[189] <- "_HH_INC_CAT2"

column.key <- read_excel('FRBNY-SCE-Public-Microdata-Complete.xlsx', sheet = 'Codebook', skip = 1)

column.key <- cbind(column.key$Question, column.key$Description)

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

ggplot(data = d3.dataset, aes(age, income_expectation, size = chance_leave_job)) + geom_point(aes(color=factor(education)))

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
aggregate(Q25v2part2 ~ month + year, d3.dataset.2, mean)

d3 <- ggplot(d3.dataset.2, aes(x=date, y=Q25v2part2)) + geom_line()
