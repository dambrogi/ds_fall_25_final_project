#Mapping tracts with and without EV Chargers in the United States
#The following plot shows a map of the entire United States and where there is 
#access to EV chargers and where there isn't within the 1 mile buffer.
#It shows there is generally more access to chargers in urban and suburban areas and much less in rural areas.
#Furthermore, there is more concentration of charger access along the West Coast and Northeast, which are both 
#highly populous areas. This maps provides a large overview of what charger access looks like across the U.S. 
#and it is clear that chargers are more accessible in areas with more population density. 

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

# Charger Access in Virginia
#The plot below takes a deeper look at the charger access map, and focuses just on the state of Virginia. 
#It clearly shows that EV chargers are clustered in specific areas and not evenly distributed. 
#There are high concentration of chargers in Northern Virginia, Richmond, and Virginia Beach. Furthermore,
#the chargers tend to cluster around interstate highways. Intuitively, this makes sense that 
#the more popular areas tend to have more access to EV chargers. 

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
#The other state that we looked at more deeply was California, there was a clear high access to 
#chargers in California specifically, so it is interesting to identify where there are gaps in such a
#saturated area. Similar to the map of Virginia, California's chargers are also concentrated most strongly in the Bay Area,
#LA, and San Diego. There is more charger clusters in rural areas such as Central Valley. California exemplifies
#a high investment and adoption scenario for EV chargers and can be used as a blueprint for the rest of the country. 

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

#Scatter plot between EV Chargers and Population below Poverty 
#This last plot is a scatter plot between EV charger access and how much of the population 
#is below the poverty line. It shows a relatively weak positive association between the 
#two variables. The positive trend that is reflected in the plot is likely a result of more charger
#access in urban areas, rather than equity in distribution. Further enforces the point that there
#are a number of geographic factors that influence charger access and may not determined by equity.

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


#Summarizing / Visualizing Distribution of # of Chargers

acs_with_access %>%
  ggplot(aes(x = chargers_accessible)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Accessible EV Chargers by Census Tract",
    x = "Number of Accessible Chargers",
    y = "Number of Census Tracts"
  ) +
  theme_minimal()

acs_with_access %>%
  summarize(
    n_tracts = n(),
    min = min(chargers_accessible, na.rm = TRUE),
    p10 = quantile(chargers_accessible, 0.10, na.rm = TRUE),
    p25 = quantile(chargers_accessible, 0.25, na.rm = TRUE),
    median = median(chargers_accessible, na.rm = TRUE),
    mean = mean(chargers_accessible, na.rm = TRUE),
    p75 = quantile(chargers_accessible, 0.75, na.rm = TRUE),
    p90 = quantile(chargers_accessible, 0.90, na.rm = TRUE),
    max = max(chargers_accessible, na.rm = TRUE)
  )

