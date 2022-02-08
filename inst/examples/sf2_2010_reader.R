library(sfreader)
library(dplyr)
library(tigris)
library(sf)
library(RSQLite)

# Initialize our reader. It expects all the files to be in the specified
# directory, in the format given after unzipping Summary File from
# https://www.census.gov/data/datasets/2010/dec/summary-file-2.html
reader = sf2_2010_reader$new("C:/Users/raim0001/Documents/datasets/sf2_2010/Oklahoma/")
reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

# Now write the data to a SQLite database. For now, let's just work with
# PCT1 (Total Population) and PCT3 (Sex x Age)
sqlite_file = "sf2_2010.sqlite"
unlink(sqlite_file)
conn = dbConnect(RSQLite::SQLite(), sqlite_file)
reader$write_sqlite(conn, target_tables = c("PCT1", "PCT3"))
dbDisconnect(conn)

conn = dbConnect(RSQLite::SQLite(), sqlite_file)
dbListTables(conn)
dbListFields(conn, "Geo_050")
dbListFields(conn, "PCT1")
dbListFields(conn, "PCT3")

dbGetQuery(conn, statement = "select NAME, LOGRECNO from Geo_050")
dbGetQuery(conn, statement = "select * from PCT1")
dbGetQuery(conn, statement = "select * from PCT3")
dbGetQuery(conn, statement = "select `Iteration Code` from Iterations")

q_out = dbGetQuery(conn, statement = "
select g.REGION, g.DIVISION, g.STATE, g.COUNTY, p.*
from Geo_050 g, PCT1 p
where g.FILEID == p.FILEID
and g.LOGRECNO == p.LOGRECNO
")

q_out = dbGetQuery(conn, statement = "
select g.REGION, g.DIVISION, g.STATE, g.COUNTY, p.CHARITER, p.LOGRECNO,
       p.PCT0010001, it.Iterations
from Geo_050 g, PCT1 p, Iterations it
where g.FILEID == p.FILEID
and g.LOGRECNO == p.LOGRECNO
and p.CHARITER == it.`Iteration Code`
")

q_out = dbGetQuery(conn, statement = "select * from Iterations")
View(q_out)

# Let's get results for detailed group "Chinese Alone"
q_out = dbGetQuery(conn, statement = "
select g.REGION, g.DIVISION, g.STATE, g.COUNTY, p.*
from Geo_050 g, PCT1 p
where g.FILEID == p.FILEID
and g.LOGRECNO == p.LOGRECNO
and p.CHARITER = '016'
")

data(fips_codes)
county_fips = fips_codes %>% filter(state_code == '40')
q_out %>%
	inner_join(county_fips, by = c('COUNTY' = 'county_code')) %>%
	select(STATE, COUNTY, COUNTY_NAME = county, PCT0010001)
