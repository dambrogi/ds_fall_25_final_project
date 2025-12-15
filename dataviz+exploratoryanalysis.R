#Mapping tracts with and without EV Chargers
library(ggplot2)
library(dplyr)
library(sf)

ggplot(acs_with_access) +
  geom_sf(aes(fill = has_charger), color = NA) +
  scale_fill_manual(values = c("TRUE" = "blue", "FALSE" = "red"),
                    labels = c("TRUE" = "Has charger access", "FALSE" = "No charger access")) +
  labs(
    title = "Census Tracts With and Without EV Charger Access (1-mile buffer)",
    fill = NULL
  ) +
  theme_minimal()
#Charger Access in Virginia
va_tracts <- acs_with_access %>%
  filter(STATEFP == "51")

ggplot(va_tracts) +
  geom_sf(aes(fill = has_charger), color = NA) +
  scale_fill_manual(
    values = c("TRUE" = "blue", "FALSE" = "red"),
    labels = c("TRUE" = "Has charger access", "FALSE" = "No charger access")
  ) +
  labs(
    title = "Virginia Census Tracts With and Without EV Charger Access (1-mile buffer)",
    fill = NULL
  ) +
  theme_minimal()

#Charger Access in California 
ca_tracts <- acs_with_access %>%
  filter(STATEFP == "06")

ggplot(ca_tracts) +
  geom_sf(aes(fill = has_charger), color = NA) +
  scale_fill_manual(
    values = c("TRUE" = "blue", "FALSE" = "red"),
    labels = c("TRUE" = "Has charger access", "FALSE" = "No charger access")
  ) +
  labs(
    title = "California Census Tracts With and Without EV Charger Access (1-mile buffer)",
    fill = NULL
  ) +
  theme_minimal()