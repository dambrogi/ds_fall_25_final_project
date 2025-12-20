# Intro to Data Science - Final Project - Drew Ambrogi and Ameenah Habib

## Main Dataset

The main dataset is the df `acs_with_access`. 

It contains all census tracts in the US (including DC, excluding PR and other territories).

It includes the following variables:

| Variable | Format | Meaning |
|----------|---------|---------|
| STATEFP | character | State FIPS |
| COUNTYFP | character | County FIPS |
| TRACTCE | character | Tract code |
| GEOIDFQ | character |  |
| GEOID | character |  |
| NAME | character |  |
| NAMELSAD | character |  |
| STUSPS | character | State postal code |
| NAMELSADCO | character |  |
| STATE_NAME | character |  |
| LSAD | character |  |
| ALAND | numeric |  |
| AWATER | numeric |  |
| name | character |  |
| pop_total | numeric | Total tract pop |
| white_nh | numeric | White nh pop |
| black_nh | numeric | Black nh pop |
| asian_nh | numeric | Asian nh pop |
| hispanic | numeric | Hispanic Latino pop|
| med_hh_income | numeric |  |
| pov_total | numeric | Poverty universe |
| pov_below | numeric | Pop below poverty line |
| lf_total | numeric | Labor force total |
| lf_unemployed | numeric | Unemployed pop |
| occ_units_total | numeric | Total occupied housing units |
| occ_units_rent | numeric | Total renter occupied housing units |
| units_10plus | numeric | Total units in large multifamily |
| hh_vehicles_total | numeric | Houshold vehicles universe  |
| hh_zero_veh | numeric | Households with 0 vehicle access |
| commute_total | numeric | Commuter universe |
| commute_car_alone | numeric | Pop that commute in car alone |
| commute_carpool | numeric | Pop that commutes (carpool) |
| pct_white_nh | numeric |  |
| pct_black_nh | numeric |  |
| pct_asian_nh | numeric |  |
| pct_hispanic | numeric |  |
| pov_rate | numeric |  |
| unemprate | numeric |  |
| renter_share | numeric |  |
| multifam_share | numeric |  |
| zero_veh_share | numeric |  |
| commute_car_share | numeric |  |
| chargers_accessible | numeric | Number of chargers accessible (1 mile buffer) |
| geometry | sfc_MULTIPOLYGON |  |
| has_charger | logical | True if chargers > 0 for the tract, false if no charger available |
| charger_cat | ordered factor | Charger density category: "None", "Very low", "Low–moderate", "High", or "Very high" |


Chargers limited to public chargers only. 


Chargers codebook: https://afdc.energy.gov/data_download/historical_stations_format 


Justification for 1 Mile buffer: https://www.ibtta.org/sites/default/files/documents/Advocacy/IBTTA-NEVI-Program-Guide-FINAL-2022-0328.pdf