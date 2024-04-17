# Packages ----------------------------------------------------------------
library(tidyverse)
library(rvest)
library(polite)

source("scripts/99-custom-functions.R")

# Setting Polite Session --------------------------------------------------
session <- bow("https://sreview.soc.cas.cz/archive.php")

# Scraping Issue Links ----------------------------------------------------
issue_links <- session |> 
  scrape() |> 
  html_elements("#content .tt") |> 
  html_attr("href")

# Tidying into a dataframe
issues_df <- tibble(name = str_extract(issue_links, pattern = "\\d{4}/mn\\d"),
                    issue_link = issue_links) |> 
  separate(col = name, sep = "/", into = c("year", "issue")) |> 
  mutate(issue = str_replace(issue,
                             pattern = "mn",
                             replacement = "")) |> 
  mutate(across(.cols = c(year, issue),
                .fns = as.numeric))

# Scraping Article Links --------------------------------------------------
articles_df <- issues_df |>
  filter(year >= 2009) |> # Articles' details has only been published on site since 2009
  mutate(article_link = map(issue_link,
                        ~{session |> 
                            nod(.x) |> 
                            scrape() |> 
                            html_elements("a.ma") |> 
                            html_attr("href")
                          })) |> 
  unnest(article_link)

# Scraping Article Content ------------------------------------------------
# Elements to be scraped
elements <- c(title = ".articleTitle",
              authors = ".authors",
              affiliation = ".affiliation",
              annotation = ".annotation",
              tags = ".low")

articles_df <- articles_df |> 
  mutate(content = map(article_link,
                        ~scrape_article(article = .x))) |> 
  unnest(content)

# Export Data -------------------------------------------------------------
write_csv(articles_df, "data-input/articles.csv")

