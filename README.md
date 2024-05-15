# What are Czech sociologists writing about? Czech Sociology through the lenses of topic models

Repository for the project focused on analysing abstracts from [Czech Sociological Review](https://sreview.soc.cas.cz/) published between 2009-2024. Here, you can find all scripts, datasets and all the other stuff.

## Slides

Slides for the talk given at the Departmen of Sociology, Charles Faculty in May 2024 can be found [here](https://github.com/alesvomacka/csr-scraping/blob/main/2024-05-csr-slides.pdf) (in Czech).

## Data

The final dataset used for analysis can be found in the `data-output` folder. It contains all scraped article abstracts, gender of first authors and assigned topic, including probabilities. The original dataset as first scraped can be found in `data-input` folder.

## Scripts

Scripts used to perform the analysis can be found in the `scripts` folder. Web scraping and API use was done using the [{polite}](https://dmi3kno.github.io/polite/) and [{httr2}](https://httr2.r-lib.org/) packages for R. Topic modeling performed through Python's [{bertopics}](https://maartengr.github.io/BERTopic/index.html). Data analysis and plotting was again done in R with [{tidyverse}](https://www.tidyverse.org/), [{brms}](https://paul-buerkner.github.io/brms/) and [{marginaleffects}](https://marginaleffects.com/).
