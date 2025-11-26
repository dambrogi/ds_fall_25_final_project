library(tidyverse)
library(httr)
library(jsonlite)
library(janitor)
library(tidycensus)
library(purrr)
library(tigris)
library(sf)


# for this to work you need a census api key and NREL api key in your .Renviron
# get an NREL API key here: https://developer.nrel.gov/signup
# open your .Renv with `file.edit("~/.Renviron")`
# store as NREL_API_KEY='yourkey' (with ' ' on either side)
# save the .Renviron file and reboot R before proceeding

#create data directory for caching 

if (!dir.exists("data")) dir.create("data")

refresh_data <- FALSE # set to TRUE if you want to re-pull data from API

#only pulls data if it hasn't already been cached locally

if (file.exists("data/chargers_sf.rds") && 
    file.exists("data/chargers_buffers_1mi.rds") && 
    !refresh_data)
{
  chargers_sf <- read_rds("data/chargers_sf.rds")
  chargers_buffers_1mi <- read_rds("data/chargers_buffers_1mi.rds")
} else {
  
  #Read API Key from env file
  
  nrel_key <- Sys.getenv("NREL_API_KEY")
  
  # Build and Send Request
  
  base_url <- "https://developer.nrel.gov/api/alt-fuel-stations/v1.json"
  
  params <- list(
    api_key   = nrel_key,
    fuel_type = "ELEC",    # electric
    access    = "public",  # public access_code
    country   = "US",      # US stations
    status    = "E",       # only available stations
    limit     = "all"      # return all in one response
  )
  
  chargers_json <- GET(base_url, query = params)
  
  # Check the response
  http_status(chargers_json)
  
  #parse the response
  chargers_text_json <- content(chargers_json, as = "text")
  
  chargers_parsed_json <- fromJSON(chargers_text_json, flatten = TRUE)
  
  chargers <- as_tibble(chargers_parsed_json$fuel_stations)
  
  chargers <- chargers |>
    select(
      id,
      station_name,
      street_address,
      city, 
      state,
      zip,
      plus4,
      restricted_access,
      access_detail_code,
      owner_type_code,
      facility_type,
      ev_level1_evse_num,
      ev_level2_evse_num,
      ev_connector_types,
      ev_network,
      ev_renewable_source,
      funding_sources,
      geocode_status,
      latitude,
      longitude,
      open_date
    )
  
  
  # turn latitude and longitude into geometries
  
  chargers_sf <- chargers |>
    # drop rows with missing coords
    filter(!is.na(latitude), !is.na(longitude)) |>
    st_as_sf(
      coords = c("longitude", "latitude"),  
      crs    = 4326,                        
      remove = FALSE                       
    )
  
  chargers_sf <- st_transform(chargers_sf, 5070) #change to projected CRS in meters, for buffers
  
  chargers_buffers_1mi <- st_buffer(chargers_sf, dist = 1609.34) #creates one mile buffers
  
  #cache locally to avoid repeat pulls
  
  write_rds(chargers_sf, "data/chargers_sf.rds")
  write_rds(chargers_buffers_1mi, "data/chargers_buffers_1mi.rds")
  
}

# Pulling census tract data

# only pulls data if it isn't locally saved

if (file.exists("data/acs_clean_sf.rds") &&  !refresh_data) {
  acs_clean_sf <- readr::read_rds("data/acs_clean_sf.rds")
} else {
  
  # define variables
  
  acs_year <- 2023
  acs_survey <- "acs5"
  
  acs_vars <- c(
    pop_total        = "B01003_001",  # Total pop
    
    white_nh         = "B03002_003",  # White alone, not Hispanic/Latino
    black_nh         = "B03002_004",  # Black alone, not Hispanic/Latino
    asian_nh         = "B03002_006",  # Asian alone, not Hispanic/Latino
    hispanic         = "B03002_012",  # Hispanic or Latino (any race)
    
    med_hh_income    = "B19013_001",  # Median hh income
    
    pov_total        = "B17001_001",  # Poverty universe
    pov_below        = "B17001_002",  # Below poverty
    
    lf_total         = "B23025_002",  # In labor force
    lf_unemployed    = "B23025_005",  # Unemployed
    
    occ_units_total  = "B25003_001",  # Occupied housing units
    occ_units_rent   = "B25003_003",  # Renter occupied
    
    units_10plus     = "B25024_010",  # Units in large multifamily
    
    hh_vehicles_total = "B08201_001", # Households by vehicles available
    hh_zero_veh       = "B08201_002", # No vehicle available
    
    commute_total     = "B08301_001", # Workers by means of transportation to work
    commute_car_alone = "B08301_002", # Car, truck, van, drove alone
    commute_carpool   = "B08301_003"  # Car, truck, van, carpooled
  )
  
  # helper function to pull state by state
  
  get_state_acs <- function(state_abbr) {
    get_acs(
      geography = "tract",
      state     = state_abbr,
      year      = acs_year,
      survey    = acs_survey,
      variables = acs_vars,
      geometry  = FALSE,   # will get from TIGRIS
      output    = "wide"   # one column per variable, w e/m suffixes
    )
  }
  
  # get list of states, pull ACS for each with purr , dropping territories
  
  data("fips_codes")
  
  states_vec <- unique(fips_codes$state)
  states_vec <- states_vec[!states_vec %in% c("PR", "AS", "GU", "MP", "UM", "VI")]
  
  acs_tract_raw <- purrr::map_dfr(states_vec, get_state_acs)
  
  # cleaning the data
  
  acs_clean <- acs_tract_raw %>%
    transmute(
      GEOID,
      name = NAME,
      
      pop_total        = pop_totalE,
      
      white_nh         = white_nhE,
      black_nh         = black_nhE,
      asian_nh         = asian_nhE,
      hispanic         = hispanicE,
      
      med_hh_income    = med_hh_incomeE,
      
      pov_total        = pov_totalE,
      pov_below        = pov_belowE,
      
      lf_total         = lf_totalE,
      lf_unemployed    = lf_unemployedE,
      
      occ_units_total  = occ_units_totalE,
      occ_units_rent   = occ_units_rentE,
      
      units_10plus     = units_10plusE,
      
      hh_vehicles_total = hh_vehicles_totalE,
      hh_zero_veh       = hh_zero_vehE,
      
      commute_total     = commute_totalE,
      commute_car_alone = commute_car_aloneE,
      commute_carpool   = commute_carpoolE
    ) %>%
    mutate(
      # race shares
      pct_white_nh  = white_nh  / pop_total,
      pct_black_nh  = black_nh  / pop_total,
      pct_asian_nh  = asian_nh  / pop_total,
      pct_hispanic  = hispanic  / pop_total,
      
      # poverty rate
      pov_rate      = if_else(pov_total > 0, pov_below / pov_total, NA_real_),
      
      # unemployment rate
      unemprate     = if_else(lf_total > 0, lf_unemployed / lf_total, NA_real_),
      
      # renter share
      renter_share  = if_else(occ_units_total > 0, occ_units_rent / occ_units_total, NA_real_),
      
      # large multifamily share (relative to occupied units)
      multifam_share = if_else(occ_units_total > 0, units_10plus / occ_units_total, NA_real_),
      
      # zero vehicle households share
      zero_veh_share = if_else(hh_vehicles_total > 0, hh_zero_veh / hh_vehicles_total, NA_real_),
      
      # share commuting by car (alone plus carpool)
      commute_car_share = if_else(
        commute_total > 0,
        (commute_car_alone + commute_carpool) / commute_total,
        NA_real_
      )
    )
  
  # get geometries for tracts from TIGRIS
  
  get_state_tract_shapes <- function(state_abbr) {
    tracts(
      state = state_abbr,
      year  = acs_year,
      cb    = TRUE  
    )
  }
  
  tract_shapes <- purrr::map_dfr(states_vec, get_state_tract_shapes)
  
  # join geometries and demographic info 
  
  acs_clean_sf <- tract_shapes %>%
    left_join(acs_clean, by = "GEOID")
  
  write_rds(acs_clean_sf, "data/acs_clean_sf.rds")
  
}


# Merging the datasets

acs_clean_sf_5070 <- st_transform(acs_clean_sf, st_crs(chargers_buffers_1mi)) #sets to same CRS

#joins charger buffers to tracts - tracts listed for each charger that intersects

tract_charger_pairs <- st_join(
  acs_clean_sf_5070,
  chargers_buffers_1mi %>%
    #preserve only select vars from chargers dataset
    select( 
      id,
      owner_type_code,
      facility_type,
      ev_level1_evse_num,
      ev_level2_evse_num,
      ev_connector_types,
      ev_network,
      ev_renewable_source,
      funding_sources
    ),  
  join = st_intersects,
  left = TRUE
)

#extract charger counts for each tract


tract_charger_counts <- tract_charger_pairs %>%
  st_drop_geometry() %>%       
  group_by(GEOID) %>%
  summarise(
    chargers_accessible = n_distinct(id, na.rm = TRUE),
    .groups = "drop"
  )

# join charger counts back to ACS data

acs_with_access <- acs_clean_sf_5070 %>%
  left_join(tract_charger_counts, by = "GEOID") %>%
  mutate(
    chargers_accessible = replace_na(chargers_accessible, 0L),
    has_charger  = chargers_accessible > 0
  )

write_rds(acs_clean_sf, "data/acs_with_access.rds")

#test that it worked with a heatmap based of tracts based on count of chargers
#limited to continental us

test_map <- acs_with_access |>
  filter(!STATEFP %in% c("02", "15", "72")) |>
  ggplot() +
  geom_sf(aes(fill = chargers_accessible), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
  coord_sf() +
  labs(
    title = "Public EV chargers within 1 mile of each census tract",
    fill  = "Chargers"
  ) +
  theme_minimal()

test_map

names(acs_with_access)
