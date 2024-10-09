# What are Czech sociologists writing about? Czech Sociology through the lenses of topic models

Repository for the project focused on analysing abstracts from [Czech Sociological Review](https://sreview.soc.cas.cz/) published between 2009-2024. You can find all scripts, datasets  and slides here.

## Slides

Slides for the talk given at the Department of Sociology, Charles University in May 2024 can be found [here](https://github.com/alesvomacka/csr-scraping/blob/main/2024-05-csr-slides.pdf) (in Czech).

Slides for the talk given at the Olomouc Sociology conference in October 2024 can be found [here](https://github.com/alesvomacka/csr-scraping/blob/main/2024-olomouc-conference-slides.pdf) (in Czech).

## Data

The final dataset used for analysis can be found in the `data-output` folder. It contains all scraped article abstracts, gender of first authors and assigned topic, including probabilities. The original dataset as first scraped can be found in `data-input` folder.

## Scripts

Scripts used to perform the analysis can be found in the `scripts` folder. Web scraping and API use was done using the [{polite}](https://dmi3kno.github.io/polite/) and [{httr2}](https://httr2.r-lib.org/) packages for R. Topic modeling performed through Python's [{bertopics}](https://maartengr.github.io/BERTopic/index.html). Data analysis and plotting was again done in R with [{tidyverse}](https://www.tidyverse.org/), [{brms}](https://paul-buerkner.github.io/brms/) and [{marginaleffects}](https://marginaleffects.com/).

## Literature
- de Melo, T., & Merialdo, P. (2024). Beyond Topic Modeling: Comparative Evaluation of Topic Interpretation by Large Language Models. In K. Arai (Ed.), Intelligent Systems and Applications (pp. 215–230). Springer Nature Switzerland. https://doi.org/10.1007/978-3-031-66336-9_16
- Egger, R., & Yu, J. (2022). A Topic Modeling Comparison Between LDA, NMF, Top2Vec, and BERTopic to Demystify Twitter Posts. Frontiers in Sociology, 7. https://doi.org/10.3389/fsoc.2022.886498
- Gokcimen, T., & Das, B. (2024). Exploring climate change discourse on social media and blogs using a topic modeling analysis. Heliyon, 10(11). https://doi.org/10.1016/j.heliyon.2024.e32464
- Lindelöf, G., Aledavood, T., & Keller, B. (2023). Dynamics of the Negative Discourse Toward COVID-19 Vaccines: Topic Modeling Study and an Annotated Data Set of Twitter Posts. Journal of Medical Internet Research, 25(1), e41319. https://doi.org/10.2196/41319
- Linton, A.-G., Dimitrova, V., Downing, A., Wagland, R., & Glaser, A. (2023). Weakly Supervised Text Classification on Free Text Comments in Patient-Reported Outcome Measures (No. arXiv:2308.06199). arXiv. https://doi.org/10.48550/arXiv.2308.06199
- Salaün, O., Gotti, F., Langlais, P., & Benyekhlef, K. (2022). Why Do Tenants Sue Their Landlords? Answers from a Topic Model. In E. Francesconi, G. Borges, & C. Sorge (Eds.), Frontiers in Artificial Intelligence and Applications. IOS Press. https://doi.org/10.3233/FAIA220454
- Sharifian-Attar, V., De, S., Jabbari, S., Li, J., Moss, H., & Johnson, J. (2022). Analysing Longitudinal Social Science Questionnaires: Topic modelling with BERT-based Embeddings. 2022 - IEEE International Conference on Big Data (Big Data), 5558–5567. https://doi.org/10.1109/BigData55660.2022.10020678
- Uncovska, M., Freitag, B., Meister, S., & Fehring, L. (2023). Rating analysis and BERTopic modeling of consumer versus regulated mHealth app reviews in Germany. Npj Digital Medicine, 6(1), 1–15. https://doi.org/10.1038/s41746-023-00862-3
- Williams, C. Y. K., Li, R. X., Luo, M. Y., & Bance, M. (2023). Exploring patient experiences and concerns in the online Cochlear implant community: A cross-sectional study and validation of automated topic modelling. Clinical Otolaryngology, 48(3), 442–450. https://doi.org/10.1111/coa.14037
