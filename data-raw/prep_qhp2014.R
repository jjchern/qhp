
# Download 2014 Health Plan Data ------------------------------------------

library(dplyr)
library(readxl)
library(magrittr)

url = "https://data.healthcare.gov/download/ga2z-ezhp/application/zip"
lcl_zip = "data-raw/imm.zip"
if (!file.exists(lcl_zip)) download.file(url, lcl_zip)
unzip(lcl_zip, exdir = "data-raw")

url_id = "https://data.healthcare.gov/download/mudy-c8dk/application/zip"
lcl_id_zip = "data-raw/imm_id.zip"
if (!file.exists(lcl_id_zip)) download.file(url_id, lcl_id_zip)
unzip(lcl_id_zip, exdir = "data-raw")

url_nm = "https://data.healthcare.gov/download/q3bc-76k2/application/zip"
lcl_nm_zip = "data-raw/imm_nm.zip"
if (!file.exists(lcl_nm_zip)) download.file(url_nm, lcl_nm_zip)
unzip(lcl_nm_zip, exdir = "data-raw")

imm = read_excel("data-raw/Individual_Market_Medical_8_11_14.xlsx")
imm_id = read_excel("data-raw/ID_Individual_Market_Medical_8_11_14.xlsx")
imm_nm = read_excel("data-raw/NM_Individual_Market_Medical_8_11_14.xlsx")

# Add New Mexico and Idaho ------------------------------------------------
qhp2014 = imm %>% bind_rows(imm_nm) %>% bind_rows(imm_id)

# Edit variable names -----------------------------------------------------
library(stringr)
names(qhp2014) = names(qhp2014) %>%
  tolower() %>%
  str_replace_all(" - ", " ") %>%
  str_replace_all("-", " ") %>%
  str_replace_all("\\(", " ") %>%
  str_replace_all("\\)", " ") %>%
  str_replace_all(",", " ") %>%
  str_replace_all("  ", " ") %>%
  str_trim() %>%
  str_replace_all(" ", "_") %>%
  str_replace_all("\\+", "_")


# From wide to long -------------------------------------------------------

# qhp2014 %<>% tidyr::gather(group, premium, premium_child:individual_3_or_more_children_age_50)
# View(imm)

# Add statefip ------------------------------------------------------------
qhp2014 %<>% left_join(fips::fips, by = c("state" = "usps"))

# Save the data
devtools::use_data(qhp2014, overwrite = TRUE)

# Delete zip files --------------------------------------------------------

unlink(lcl_zip)
unlink(lcl_id_zip)
unlink(lcl_nm_zip)
unlink(Sys.glob("data-raw/*.xlsx"))
