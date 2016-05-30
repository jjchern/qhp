library(dplyr, warn.conflicts = FALSE)

# Download 2016 Plan selections by ZIP Code for the 38 states -------------
# Source: https://aspe.hhs.gov/basic-report/plan-selections-zip-code-and-county-health-insurance-marketplace-march-2016
# (November 1, 2015 – February 1, 2016), including SEP activity through Feb. 22, 2015)
# Count: 9.63 million plan selections for 38 states

url = "https://aspe.hhs.gov/sites/default/files/aspe-files/187796/mar2016marketplacezipcode_1.xlsx"
lcl = "data-raw/mar2016marketplacezipcode_1.xlsx"
if (!file.exists(lcl)) download.file(url, lcl)

enrollment2016 = readxl::read_excel(lcl, skip = 21, sheet = 1)
enrollment2016_county = readxl::read_excel(lcl, skip = 21, sheet = 2)

enrollment2016 %>%
  names() %>%
  tolower() %>%
  stringi::stri_trans_totitle() %>%
  stringr::str_replace_all(" ", "") ->
  names(enrollment2016)


enrollment2016 %>%
  mutate(
    ZipCode = as.integer(ZipCode),
    PlanSelections = as.integer(PlanSelections)
  ) -> enrollment2016

enrollment2016

# Zip code to county link file --------------------------------------------

# devtools::install_github("jjchern/zcta")
# devtools::install_github("jjchern/gaze")
# devtools::install_github("jjchern/zipzcta")

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

enrollment2016 %>%
  left_join(zipcounty, by = c("ZipCode" = "zip")) -> enrollment2016

# Save --------------------------------------------------------------------

enrollment2016
devtools::use_data(enrollment2016, overwrite = TRUE)

