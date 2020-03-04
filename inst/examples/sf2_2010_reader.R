library(sfreader)
library(dplyr)
library(tigris)
library(sf)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File from
# https://www.census.gov/data/datasets/2010/dec/aian-summary-file.html
reader = sf2_2010_reader$new("C:/Users/raim0001/Documents/datasets/sf2_2010/Oklahoma/")
reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

# Now write the data to a SQLite database...
