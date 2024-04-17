# Data and Packages -------------------------------------------------------
library(tidyverse)
library(stringi)
library(httr2)

articles <- read_csv("data-input/articles.csv")

# Cleaning Authors and Affiliations ---------------------------------------

articles <- articles |> 
  mutate(authors = str_replace_all(authors,
                                   pattern = "\\d+",
                                   replacement = ""),
         authors = str_replace_all(authors,
                                   pattern = ",,",
                                   replacement = ","),
         affiliation = str_replace(affiliation,
                                   pattern = "\\d\n",
                                   replacement = ""),
         affiliation = str_replace_all(affiliation,
                                       pattern = "\\d+",
                                       replacement = ""),
         affiliation = str_squish(affiliation),
         id = row_number()) |> 
  relocate(id)

# Dropping non-articles ---------------------------------------------------
articles <- filter(.data = articles,!is.na(annotation) & !is.na(tags))

# Setting first author gender ---------------------------------------------
## genderize.io requires input in lower case ASCII, without diacritics.
articles <- articles |> 
  mutate(first_author = str_split(authors, pattern = ","),
         first_author = map_chr(first_author, ~.x[1]),
         first_author = str_extract(first_author, pattern = "([^\\s]+)"),
         first_author = stri_trans_general(first_author, "latin-ascii"),
         first_author = str_to_lower(first_author))

first_names <- unique(articles$first_author)

## First try specifying Czech republic, to get better estimates
## As of April 2024, there is a limit of 100 requests per day for free users.
## Either split the names into two batches and run across 2 days or fork out $10.
genders <- map(.x = first_names,
               ~request("https://api.genderize.io") |> 
                 req_url_query(name = .x, country_id = "CZ") |>
                 req_perform()) |> 
  map(resp_body_json) %>% 
  map(~tibble(name = .$name,
              gender = .$gender,
              prob = .$probability,)) |> 
  bind_rows()

## Few names are not Czech, run them separately
names_nonczech <- genders |> 
  filter(is.na(gender)) |> 
  pull(name)

## Merge everything together
genders_nonczech <- map(.x = names_nonczech,
               ~request("https://api.genderize.io") |> 
                 req_url_query(name = .x) |>
                 req_perform()) |> 
  map(resp_body_json) %>% 
  map(~tibble(name = .$name,
              gender = .$gender,
              prob = .$probability,)) |> 
  bind_rows()

articles <- genders |> 
  filter(!is.na(gender)) |> 
  bind_rows(genders_nonczech) |> 
  select(-prob) |> 
  right_join(articles, by = c("name" = "first_author")) |> 
  rename(first_author_gender = gender) |> 
  relocate(first_author_gender, .after = authors) |> 
  select(-name)

# Identifying english issues ----------------------------------------------
## Every 3rd issue is in english.
articles$language <- if_else(articles$issue %% 3 == 0, "english", "czech")

# Cleaning tag words ------------------------------------------------------
articles$tags <- str_replace(articles$tags, pattern = "Klíčová slova: ", replacement = "")

# Export data -------------------------------------------------------------
write_csv(articles, "data-processed/articles.csv")
