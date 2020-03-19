library(sfreader)
library(dplyr)
library(tigris)
library(sf)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File from
# https://www.census.gov/data/datasets/2010/dec/aian-summary-file.html
reader = aiansf_2010_reader$new("C:/Users/raim0001/Documents/datasets/aian_2010/National/")
reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

# Now write the data to a SQLite database. For now, let's just work with
# PCT1 (Total Population) and PCT3 (Sex x Age)
sqlite_file = "aiansf_2010.sqlite"
unlink(sqlite_file)
conn = dbConnect(RSQLite::SQLite(), sqlite_file)
# reader$write_sqlite(conn, target_tables = c("PCT1", "PCT3"))
reader$write_sqlite(conn, target_tables = c("PCT1"))
dbDisconnect(conn)

conn = dbConnect(RSQLite::SQLite(), sqlite_file)
dbListTables(conn)
q_geo = dbGetQuery(conn, statement = "select * from Geo_050")
q_pct1 = dbGetQuery(conn, statement = "select * from PCT1")
q_iter = dbGetQuery(conn, statement = "select * from Iterations")
q_out = dbGetQuery(conn, statement = "
	select g.STATE, g.county, g.name, p.*, i.Description
	from Geo_050 g, PCT1 p, Iterations i
	where g.LOGRECNO = p.LOGRECNO
	and p.CHARITER = i.Code
	and g.STATE = '40'
")
View(q_out)
dbDisconnect(conn)
