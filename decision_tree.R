library(tidyverse)
library(rpart)
library(parsnip)
library(tidymodels)
library(rpart.plot)
library(vip)

#selects only relevant predictors, drops duplicative ones, n.a.

predictors <- c(
  "pop_density",
  "med_hh_income",
  "pct_white_nh",
  "pct_black_nh",
  "pct_asian_nh",
  "pct_hispanic",
  "pov_rate",
  "unemprate",
  "renter_share",
  "multifam_share",
  "zero_veh_share",
  "commute_car_share"
)

tree_model_df <- acs_with_access %>%
  st_drop_geometry() %>%
  select(charger_cat, all_of(predictors)) %>%
  na.omit()

summary(tree_model_df)

#splitting the data

set.seed(20201020)

# create a split object
tree_model_df_split <- initial_split(data = tree_model_df, prop = 0.75, strata = charger_cat)

# create the training and testing data
tree_model_df_train <- training(x = tree_model_df_split)
tree_model_df_test  <- testing(x = tree_model_df_split)

tree_rec <- recipe(charger_cat ~ ., data = tree_model_df_train)

tree_model <- decision_tree(mode = "classification") |>
  set_engine(
    "rpart",
    control = rpart.control(cp = 0.005, minsplit = 250)
  )


# workflow
tree_wf <- workflow() |>
  add_recipe(tree_rec) |>
  add_model(tree_model)

# fit
rpart_fit <- tree_wf |>
  fit(data = tree_model_df_train)

#training data predictions

train_preds <- predict(rpart_fit, tree_model_df_train, type = "class") |> 
  bind_cols(tree_model_df_train)

# testing data predictions

test_preds <- predict(rpart_fit, tree_model_df_test, type = "class") |> 
  bind_cols(tree_model_df_test)

tree_model_metrics <- tibble(
  train_precision = precision(data = train_preds, truth = charger_cat, estimate = .pred_class)$.estimate,
  train_recall = recall(data = train_preds, truth = charger_cat, estimate = .pred_class)$.estimate,
  test_precision = precision(data = test_preds, truth = charger_cat, estimate = .pred_class)$.estimate,
  test_recall = recall(data = test_preds, truth = charger_cat, estimate = .pred_class)$.estimate
)

tree_model_metrics

rpart_fit |>
  extract_fit_parsnip() |>
  vip(num_features = 10)

vip(tree_model, num_features = 10)
