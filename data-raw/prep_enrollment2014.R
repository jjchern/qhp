library(dplyr)
library(magrittr)

# Download 2014 Plan selections by ZIP Code for the 36 states -------------
# Source: http://aspe.hhs.gov/plan-selections-zip-code-health-insurance-marketplace-september-2014

if (!file.exists("data-raw/zipcode-enrollment-2014.csv")) {
  download.file(url = "http://aspe.hhs.gov/sites/default/files/aspe-files/83866/zipcode-enrollment.xlsx",
                destfile = "data-raw/zipcode-enrollment-2014.xlsx",
                quiet = TRUE)
}

enrollment2014 = readxl::read_excel(path = "data-raw/zipcode-enrollment-2014.xlsx",
                             skip = 19,
                             na = "*")

names(enrollment2014) %<>%
  tolower() %>%
  stringi::stri_trans_totitle() %>%
  stringr::str_replace_all(" ", "")

enrollment2014 %<>%
  mutate(ZipCode = as.integer(ZipCode),
         PlanSelections = as.integer(`PlanSelections`))

enrollment2014

# Zip code to county link file --------------------------------------------

zctacounty = zcta::zcta_county_rel_10 %>%
  select(zcta5, state, county, geoid, poppt, zpoppct) %>%
  group_by(zcta5) %>%
  slice(which.max(zpoppct)) %>%
  left_join(gaze::county10, by = "geoid") %>%
  select(zcta5, state, usps, county, geoid, name)
zctacounty

zipcounty = zipzcta::zipzcta %>%
  left_join(zctacounty, by = c("zcta" = "zcta5")) %>%
  select(zip, zcta, state = usps, countygeoid = geoid, countyname = name) %>%
  arrange(zip)
zipcounty


# Add county and county names ---------------------------------------------

enrollment2014 %<>%
  left_join(zipcounty, by = c("ZipCode" = "zip"))

# Test --------------------------------------------------------------------

# enrollment2014 %>%
#  left_join(zipcounty, by = c("ZipCode" = "zip")) %>%
#  filter(!is.na(PlanSelections)) %>%
#  filter(countygeoid %>% is.na)


# Save --------------------------------------------------------------------

enrollment2014
devtools::use_data(enrollment2014, overwrite = TRUE)

