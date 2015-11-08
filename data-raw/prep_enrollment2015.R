library(dplyr)
library(magrittr)

# Download 2015 Plan selections by ZIP Code for the 37 states -------------
# Source: http://aspe.hhs.gov/plan-selections-zip-code-health-insurance-marketplace-april-2015
# (Nov. 15, 2014 — Feb. 15, 2015, including SEP activity through Feb. 22, 2015)

url = "http://aspe.hhs.gov/sites/default/files/aspe-files/83841/2015-feb-22-marketplace-plan-selections-zip.xlsx"
lcl = "data-raw/zipcode-enrollment-2015.xlsx"
if (!file.exists(lcl)) download.file(url, lcl)

enrollment2015 = readxl::read_excel(lcl, skip = 15, na = "*")

enrollment2015 %>%
  names() %>%
  tolower() %>%
  stringi::stri_trans_totitle() %>%
  stringr::str_replace_all(" ", "") ->
  names(enrollment2015)

enrollment2015 %<>%
  mutate(ZipCode = as.integer(ZipCode),
         PlanSelections = as.integer(`PlanSelections`))

enrollment2015

# Zip code to county link file --------------------------------------------

zctacounty = zcta::zcta_county_rel_10 %>%
  select(zcta5, state, county, geoid, poppt, zpoppct, copop) %>%
  group_by(zcta5) %>%
  slice(which.max(zpoppct)) %>%
  left_join(gaze::county10, by = "geoid") %>%
  select(zcta5, state, usps, county, geoid, name, copop)
zctacounty

zipcounty = zipzcta::zipzcta %>%
  left_join(zctacounty, by = c("zcta" = "zcta5")) %>%
  select(zip, zcta, state = usps, countygeoid = geoid, countyname = name, copop) %>%
  arrange(zip)
zipcounty


# Add county and county names ---------------------------------------------

enrollment2015 %<>%
  left_join(zipcounty, by = c("ZipCode" = "zip"))

# Test --------------------------------------------------------------------

# enrollment2014 %>%
#  left_join(zipcounty, by = c("ZipCode" = "zip")) %>%
#  filter(!is.na(PlanSelections)) %>%
#  filter(countygeoid %>% is.na)


# Save --------------------------------------------------------------------

enrollment2015
devtools::use_data(enrollment2015, overwrite = TRUE)

