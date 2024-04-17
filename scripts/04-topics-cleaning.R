# Packages ----------------------------------------------------------------
library(tidyverse)

# Data --------------------------------------------------------------------
articles <- read_csv("data-processed/articles.csv")
topics <- read_csv("data-processed/topics.csv")
probs <- read_csv("data-processed/probs.csv")
reduced_topics <- read_csv("data-processed/reduced_topics.csv")

# Merging results ---------------------------------------------------------
topics <- topics |> 
  select(-`...1`) |> 
  rename(annotation = Document) |> 
  rename_with(str_to_lower) |>
  mutate(topic = case_when(name == "0_political_support_postcommunist_participation" ~ "Politics",
                           name == "1_educational_education_students_school" ~ "Education",
                           name == "2_religious_knowledge_work_culture" ~ "Knowledge/Science",
                           name == "3_care_age_old_women" ~ "Gerontology",
                           name == "4_child_children_working_mothers" ~ "Gender & Work",
                           name == "5_space_rural_place_places" ~ "Space & Time",
                           name == "6_transnational_networks_towards_attitudes" ~ "Migration",
                           name == "7_marriage_partnership_family_gender" ~ "Partnership",
                           name == "8_cultural_capital_media_distinction" ~ "Culture/Media",
                           name == "9_households_regional_successful_household" ~ "Housing",
                           name == "10_spatial_areas_rural_differentiation" ~ "Rural",
                           name == "11_environmental_change_movement_values" ~ "Environment",
                           name == "12_quality_satisfaction_version_surveys" ~ "Methodology",
                           name == "-1_institutions_exclusion_pandemic_public" ~ "Others/Unclassified")) |> 
  select(annotation, topic, top_n_words, representative_document)

## Fixing topics dataset
probs <- probs |> 
  select(-`...1`) |> 
  mutate(across(.cols = everything(),
                .fns  = ~if_else(. < 0.05, true = 0, false = .)))

names(probs) <- c("prob_politics", "probs_education", "prob_gerontology", "prob_gender", "prob_parenting", "prob_spacetime",
                  "prob_migration", "prob_partnership", "prob_culture_media", "prob_housing",
                  "prob_rural", "prob_environment", "prob_methodology")

probs[["annotation"]] <- topics[["annotation"]]
probs <- relocate(.data = probs, annotation)

## Reduced dimensions
reduced_topics <- reduced_topics |> 
  select(-`...1`) |>
  rename(dim1 = `0`,
         dim2 = `1`)
reduced_topics[["annotation"]] <- topics[["annotation"]]
reduced_topics <- relocate(.data = reduced_topics, annotation)

# Merging datasets --------------------------------------------------------
articles <- articles |> 
  left_join(topics, by = "annotation") |>
  left_join(probs, by = "annotation") |>
  left_join(reduced_topics, by = "annotation") |> 
  mutate(topic = as.factor(topic))

# Export data -------------------------------------------------------------
write_csv(articles, "data-output/articles.csv")


