library(sfreader)
library(dplyr)
library(RSQLite)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File from
# https://www.census.gov/census2000/sumfile2.html
reader = sf2_2000_reader$new("C:/Users/raim0001/Documents/datasets/sf2_2000/Rhode_Island/")
reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

# Now write the data to a SQLite database. For now, let's just work with
# PCT1 (Total Population) and PCT3 (Sex x Age)
sqlite_file = "sf2_2000.sqlite"
unlink(sqlite_file)
conn = dbConnect(RSQLite::SQLite(), sqlite_file)
# reader$write_sqlite(conn, target_tables = c("PCT1", "PCT3"))
reader$write_sqlite(conn, target_tables = c("PCT1"))
dbDisconnect(conn)

conn = dbConnect(RSQLite::SQLite(), sqlite_file)
dbListTables(conn)
dbListFields(conn, "Geo_050")
dbListFields(conn, "PCT1")
dbListFields(conn, "PCT3")

# q_out = dbReadTable(conn, "Geo_140")
q_out = dbReadTable(conn, "Geo_050")
head(q_out)
head(q_out$AREALAND)

dbDisconnect(conn)
