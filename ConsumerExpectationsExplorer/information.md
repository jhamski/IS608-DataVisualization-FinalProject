## Federal Reserve Bank of New York's (FRBNY) Survey of Consumer Expectations

The [FRBNY's Survey of Consumer Expectations (SCE)](https://www.newyorkfed.org/microeconomics/sceindex) aims to gauge American consumers’ expectations about inflation, the labor market, and household finances. The SCE is gathered monthly and includes a rich set of demographic parameters about the survey respondents. The SCE interviews approximately 1200 people who are part of a rolling panel each month, with respondents participating in the panel for approximately one year. 

Consumer expectations are important to economists due to their connection to consumption ([Doms and Morin, 2014](http://www.frbsf.org/economic-research/files/wp04-09bk.pdf)). However, the relationship between consumer expectations, aggregate consumption, and the U.S. economy as a whole is complex. As you can investigate with this FRBNY Consumer Expectations Survey Explorer Shiny App, the survey respondent's expectations often vary widely and can be contradictory. For example, when asked about the expected increase in earnings growth, home prices, gas, or food, respondents expect an increase in prices several percentage points higher than their expected rate of inflation.  

## About this Shiny App

The goal of this Shiny App is to provide researchers a quick way of investigating the SCE, potentially identifying interesting questions for further study.

This Shiny App uses two data sources from the SCE: 
- Survey Microdata, which includes respondent data. (Microdata tab)
- Survey response timeseries, based on the Microdata and cleaned, calculated, and weighted according to NYFRB methods. (Timeseries tab)

The Analysis tab features selected analysis methods for viewing the dataset, including Seasonal Decomposition of Time Series by Loess and Principle Component Analysis (PCA).