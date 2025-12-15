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

#Scatterplot between EV Chargers and Population below Poverty 
ggplot(acs_with_access, aes(x = pov_below, y = chargers_accessible)) +
  geom_point(alpha = 0.25, size = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(trans = "log1p") +
  labs(
    title = "EV Charger Access vs Population Below Poverty Line (United States)",
    x = "Population Below Poverty Line",
    y = "Accessible EV Chargers (log scale)"
  ) +
  theme_minimal()
#Initial conclusions: 
#“Nationally, EV charger access shows only a weak positive association with the
#size of the population below the poverty line, a pattern largely driven by 
#urbanization rather than targeted infrastructure equity.”
#not worth exploring state specific bc similar results 

#Chargers Accessible in VA
ggplot(va_data) +
  geom_sf(aes(fill = chargers_accessible), color = NA) +
  scale_fill_viridis_c(
    option = "plasma",   # or "viridis", "magma"
    trans = "sqrt",      # sqrt scale helps with skew
    na.value = "grey90"
  ) +
  labs(
    title = "Accessible EV Chargers by Census Tract — Virginia",
    fill = "Chargers\nAccessible"
  ) +
  theme_minimal()

#The map clearly shows that accessible EV chargers are highly clustered, 
#not evenly distributed across Virginia. High-access tracts are concentrated in:
# Northern Virginia (DC metro area), Richmond metro, Hampton Roads / Tidewater
#, Smaller clusters around college towns and urban centers
#Even without demographic variables layered on, the map shows: 
#Urban/suburban tracts = higher charger access Rural tracts = minimal or no access

