library(sfreader)
library(dplyr)
library(tigris)
library(sf)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File from
# https://www.census.gov/data/datasets/2010/dec/aian-summary-file.html
reader = aiansf2010_reader$new("C:/Users/raim0001/Documents/aian_2010_us/")
reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

# PCT3 is the Age x Sex table
# Summary level "050" represents county level
pct3_050 = reader$getTable(table_name = "PCT3", sumlev = "050", iteration = "001")
head(pct3_050)

pct3_050 = reader$getTable(table_name = "PCT3", sumlev = "050",
	iteration = "001", transform_colnames = TRUE)
head(pct3_050)

# Let's try an AIAN group now.
# iteration 01F is "Apache alone"
# Summary level "040" represents state level
pct1_040_01F = reader$getTable(table_name = "PCT3", sumlev = "040",
	iteration = "001", transform_colnames = TRUE)
head(pct1_040_01F)

# Try a slightly more interesting example...
# Let's see if there are any counties with males or females 110 or older.
# We could plot them on a map if we want
counties_sf = counties() %>% st_as_sf()
pct3_050_sf = counties_sf %>%
	inner_join(pct3_050, by = c('STATEFP' = 'STATE', 'COUNTYFP' = 'COUNTY')) %>%
	filter(`Total: Male: 110 years and over` > 0 | `Total: Female: 110 years and over` > 0) %>%
	select(STATEFP, COUNTYFP, NAMELSAD, `Total: Male: 110 years and over`,
		`Total: Female: 110 years and over`)
