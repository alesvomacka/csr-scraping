# Packages ----------------------------------------------------------------
library(tidyverse)
library(avom)
library(scales)
library(brms)
library(marginaleffects)
library(tidybayes)

# Data import -------------------------------------------------------------
articles <- read_csv("data-output/articles.csv")

# ggplot2 setup -----------------------------------------------------------
theme_set(theme_avom())

update_geom_defaults("text", list(family = "Fira Sans"))
update_geom_defaults("col", list(fill = "#83a598"))

#"#fb4934" "#b8bb26" "#83a598" "#fabd2f" "#d3869b" "#8ec07c" "#fe8019"

# Reorder topics ----------------------------------------------------------
articles <- articles |> 
  mutate(topic = fct_infreq(topic),
         topic = fct_relevel(topic, "Others/Unclassified"))


# Topic prevalence --------------------------------------------------------
plot_topic_prevalence <- articles |> 
  count(topic) |> 
  mutate(prop = n / sum(n),
         prop_label = percent(prop, accuracy = 1),
         topic = fct_reorder(topic, prop),
         topic = fct_relevel(topic, "Others/Unclassified")) |> 
  ggplot(aes(x = prop,
             y = topic)) +
  geom_col() +
  geom_text(mapping = aes(label = prop_label),
            nudge_x = 0.010) +
  geom_text(mapping = aes(label = n),
            nudge_x = -0.010,
            color = "white") +
  scale_x_continuous(labels = percent_format()) +
  labs(x = "Prevalence",
       y = "Topic",
       title = "Political sociology by far the most popular",
       caption = "n = 412. Relative frequencies in black, absolute in white.") +
  theme(panel.grid.major.y = element_blank())

model_topic_prevalence <- brm(topic ~ 1,
                              family = "categorical",
                              data = articles,
                              chains = 4,
                              cores = 4,
                              iter = 4000,
                              warmup = 1000,
                              backend = "cmdstanr",
                              file = "models/topic_prevalence")

epred_draws(model_topic_prevalence, newdata = tibble(topic = "Politics")) |> 
  median_qi() |> 
  mutate(.category = fct_reorder(.category, .epred),
         .category = fct_relevel(.category, "Others/Unclassified"),
         .epred_label = percent(.epred, accuracy = 1, suffix = "")) |> 
  ggplot(aes(x = .epred,
             xmin = .lower,
             xmax = .upper,
             y = .category,
             label = .epred_label)) +
  geom_pointrange(size = 2) +
  geom_text(color = "white") +
  scale_x_continuous(labels = percent_format()) +
  labs(x = "Prevalence",
       y = "Topic",
       title = "Political sociology by far the most popular") +
  theme(panel.grid.major.y = element_blank())

# Topic map ---------------------------------------------------------------
topics_palette <- c(RColorBrewer::brewer.pal(n = 12, name = "Paired"), "limegreen", "grey80")

plot_topic_map <- articles |> 
  mutate(topic = fct_relevel(topic, "Others/Unclassified", after = Inf)) |>
  ggplot(aes(x = dim1,
             y = dim2,
             color = topic)) +
  geom_point(size = 2, alpha = 0.9) +
  scale_color_manual(values = topics_palette) +
  labs(x = "Dimension 1",
       y = "Dimension 2",
       color = element_blank(),
       title = "Map of the Czech Sociological Review 2009-2024") +
  theme(legend.position = "bottom",
        panel.grid.major = element_blank(),
        axis.text = element_blank(),
        legend.key.spacing = unit(0.1, "cm"))

# Gender differences ------------------------------------------------------
model_topic_gender <- brm(topic ~ first_author_gender,
                          family = "categorical",
                          data = articles,
                          chains = 4,
                          cores = 4,
                          iter = 4000,
                          warmup = 1000,
                          backend = "cmdstanr",
                          file = "models/model_topic_gender")

plot_topic_gender_ame <- avg_slopes(model_topic_gender,
                                    variables = "first_author_gender", by = "group") |> 
  posterior_draws() |> 
  mutate(group = fct_reorder(group, draw),
         group = fct_relevel(group, "Others/Unclassified")) |> 
  ggplot(aes(x = draw,
             y = group,
             fill = after_stat(x < 0))) +
  stat_halfeye(show.legend = FALSE) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_avom(direction = -1) +
  scale_x_continuous(labels = percent_format(accuracy = 1, suffix = " p.b.")) +
  labs(x = "P(1st Author Man) - P(1st Author Woman)",
        y = "Topic",
       title = "Politics and Science dominated by men, Gender and Education by women",
       caption = "n = 412. Posterior distributions of the difference between men and women") +
  theme(panel.grid.major.x = element_blank())

plot_topic_gender_prob_dens <- avg_comparisons(model_topic_gender,
                                               variables = "first_author_gender",
                                               by = "group",
                comparison = \(hi, lo) hi/(hi + lo)) |> 
  posterior_draws() |> 
  mutate(group = fct_reorder(group, draw),
         group = fct_relevel(group, "Others/Unclassified")) |> 
  ggplot(aes(x = draw,
             y = group,
             fill = after_stat(x < 0.5))) +
  stat_halfeye(show.legend = FALSE) +
  geom_vline(xintercept = 0.5, linetype = "dashed") +
  scale_fill_avom(direction = -1) +
  scale_x_continuous(labels = percent_format(accuracy = 1, suffix = " p.b.")) +
  labs(x = "Probability of first author being male",
       y = "Topic",
       title = "Politics and Science dominated by men, Gender and Education by women",
       caption = "n = 412. Posterior distributions for the probability of first auhtor being male") +
  theme(panel.grid.major.x = element_blank())

plot_topic_gender_prob_ci <- avg_comparisons(model_topic_gender,
                                             variables = "first_author_gender",
                                             by = "group",
                comparison = \(hi, lo) hi/(hi + lo)) |> 
  mutate(group = fct_reorder(group, estimate),
         group = fct_relevel(group, "Others/Unclassified"),
         gender = case_when(conf.low > 0.5 ~ "men",
                            conf.high < 0.5 ~ "women",
                            TRUE ~ "other")) |> 
  ggplot(aes(x = estimate,
             xmin = conf.low,
             xmax = conf.high,
             color = gender,
             y = group)) +
  geom_pointrange(show.legend = FALSE) +
  geom_vline(xintercept = 0.5, linetype = "dashed") +
  scale_color_manual(values = c("#b8bb26", "#83a598", "#fb4934")) +
  scale_x_continuous(labels = percent_format(accuracy = 1, suffix = "%")) +
  labs(x = "Probability of first author being male",
       y = "Topic",
       title = "Politics and Science dominated by men, Gender and Education by women",
       caption = "n = 412. Ranges represent 95% credible intervals") +
  theme(panel.grid.major.x = element_blank())

# Time differences --------------------------------------------------------
articles$is_politics <- if_else(articles$topic == "Politics", true = 1, false = 0)
articles$is_gender <- if_else(articles$topic == "Gender & Work", true = 1, false = 0)
articles$year_issue <- paste(articles$year, articles$issue, sep = "_")
articles$year_issue <- as.factor(articles$year_issue)
articles$year_issue_num <- as.numeric(articles$year_issue)
