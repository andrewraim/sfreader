library(sfreader)
library(dplyr)
library(tigris)
library(sf)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File 1 and
# Summary File 2 from
# https://www.census.gov/data/datasets/2010/dec/aian-summary-file.html
reader = aiansf2010_reader$new("C:/Users/raim0001/Documents/aian_2010_us/")
reader$getTableNames()
reader$getSummaryLevels()

# PCT3 is the Age x Sex table
# Summary level "050" represents county level
pct3_050 = reader$getTable(table_name = "PCT3", sumlev = "050")
head(pct3_050)

# Try a slightly more interesting example...
# Let's see if there are any counties with males or females 110 or older.
# We could plot them on a map if we want
counties_sf = counties() %>% st_as_sf()
pct3_050_sf = counties_sf %>%
	inner_join(pct3_050, by = c('STATEFP' = 'STATE', 'COUNTYFP' = 'COUNTY')) %>%
	filter(PCT0030105 > 0 | PCT0030209 > 0) %>%
	select(LOGRECNO, REGION, DIVISION, STATEFP, COUNTYFP, NAMELSAD, PCT0030105, PCT0030209)
