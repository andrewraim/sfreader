Overview
========

The purpose of the `sfreader` package is to read Summary Files from the
decennial census and write the contents to a relational database (such
as SQLite) which can be easily queried. Because Summary Files each have
subtly different formats, each requires its own reader to be written.

This is a personal project of the author, and is not endorsed in any way
by the U.S. Census Bureau. The package is also currently under heavy
construction, and should not be depended upon in any serious way.

As of this writing, the 2010 SF2 and 2010 AIAN SF readers are functioning.

Installation
============

To install from Github, obtain the `devtools` package and run the
following in R.

    devtools::install_github("andrewraim/sfreader")

Example: Create a Database for 2010 Oklahoma SF2 files
======================================================

First, browse to the repository for SF2 files:
<https://www.census.gov/data/datasets/2010/dec/summary-file-2.html>
Download the file `ok2010.sf2.zip` which contains data for Oklahoma.
Unzip the contents to a folder on your local computer, say
`C:/Users/raim0001/Documents/datasets/sf2_2010/Oklahoma/`. Now we will
initialize an `sf2_2010_reader` object and point it to the files.

    library(sfreader)
    reader = sf2_2010_reader$new("C:/Users/raim0001/Documents/datasets/sf2_2010/Oklahoma/")

Our destination will be a SQLite database which resides in a file
`sf2_2010.sqlite`. Let's create the database there. To avoid using too
much space, let's just save PCT1 (Total Population) and PCT3 (Sex x
Age).

    library(RSQLite)
    sqlite_file = "sf2_2010.sqlite"
    unlink(sqlite_file)
    conn = dbConnect(RSQLite::SQLite(), sqlite_file)
    reader$write_sqlite(conn, target_tables = c("PCT1", "PCT3"))
    dbDisconnect(conn)

Example: Using the Database
===========================

Now we should be able to connect to the database whenever we like and
query it. We don't necessarily need to do this through R - we could use
any kind of client which can connect to the database. First, let's
request the list of tables.

    conn = dbConnect(RSQLite::SQLite(), sqlite_file)
    dbListTables(conn)

    ##  [1] "Geo_040"       "Geo_050"       "Geo_060"       "Geo_070"      
    ##  [5] "Geo_080"       "Geo_140"       "Geo_144"       "Geo_155"      
    ##  [9] "Geo_158"       "Geo_160"       "Geo_261"       "Geo_263"      
    ## [13] "Geo_265"       "Geo_266"       "Geo_280"       "Geo_281"      
    ## [17] "Geo_282"       "Geo_283"       "Geo_284"       "Geo_285"      
    ## [21] "Geo_320"       "Geo_321"       "Geo_322"       "Geo_340"      
    ## [25] "Geo_341"       "Geo_500"       "Geo_610"       "Geo_620"      
    ## [29] "Geo_871"       "Geo_950"       "Geo_970"       "Iterations"   
    ## [33] "PCT1"          "PCT3"          "SummaryLevels" "TableNames"

Here is a brief description of all the tables:  
- `Geo_XYZ`: Geo table for summary level `XYZ`. For example, `Geo_040`
represents states.  
- `Iterations`: List of iterations (race classifications).  
- `SummaryLevels`: List of available summary levels.  
- `TableNames`: Names and descriptions of tables in this summary file.  
- `PCT1`: The table `PCT1` for all summary levels and all iterations.  
- `PCT3`: The table `PCT3` for all summary levels and all iterations.

We can list fields in some of those tables.

    dbListFields(conn, "Geo_050")

    ##   [1] "FILEID"   "STUSAB"   "SUMLEV"   "GEOCOMP"  "CHARITER" "CIFSN"   
    ##   [7] "LOGRECNO" "REGION"   "DIVISION" "STATE"    "COUNTY"   "COUNTYCC"
    ##  [13] "COUNTYSC" "COUSUB"   "COUSUBCC" "COUSUBSC" "PLACE"    "PLACECC" 
    ##  [19] "PLACESC"  "TRACT"    "BLKGRP"   "BLOCK"    "IUC"      "CONCIT"  
    ##  [25] "CONCITCC" "CONCITSC" "AIANHH"   "AIANHHFP" "AIANHHCC" "AIHHTLI" 
    ##  [31] "AITSCE"   "AITS"     "AITSCC"   "TTRACT"   "TBLKGRP"  "ANRC"    
    ##  [37] "ANRCCC"   "CBSA"     "CBSASC"   "METDIV"   "CSA"      "NECTA"   
    ##  [43] "NECTASC"  "NECTADIV" "CNECTA"   "CBSAPCI"  "NECTAPCI" "UA"      
    ##  [49] "UASC"     "UATYPE"   "UR"       "CD"       "SLDU"     "SLDL"    
    ##  [55] "VTD"      "VTDI"     "RESERVE2" "ZCTA5"    "SUBMCD"   "SUBMCDCC"
    ##  [61] "SDELM"    "SDSEC"    "SDUNI"    "AREALAND" "AREAWATR" "NAME"    
    ##  [67] "FUNCSTAT" "GCUNI"    "POP100"   "HU100"    "INTPTLAT" "INTPTLON"
    ##  [73] "LSADC"    "PARTFLAG" "RESERVE3" "UGA"      "STATENS"  "COUNTYNS"
    ##  [79] "COUSUBNS" "PLACENS"  "CONCITNS" "AIANHHNS" "AITSNS"   "ANRCNS"  
    ##  [85] "SUBMCDNS" "CD113"    "CD114"    "CD115"    "SLDU2"    "SLDU3"   
    ##  [91] "SLDU4"    "SLDL2"    "SLDL3"    "SLDL4"    "AIANHHSC" "CSASC"   
    ##  [97] "CNECTASC" "MEMI"     "NMEMI"    "PUMA"     "RESERVED"

    dbListFields(conn, "PCT1")

    ## [1] "FILEID"     "STUSAB"     "CHARITER"   "CIFSN"      "LOGRECNO"  
    ## [6] "PCT0010001"

Here are a few simple queries.

    q_out = dbGetQuery(conn, statement = "select NAME, LOGRECNO from Geo_040")
    head(q_out)

    ##       NAME LOGRECNO
    ## 1 Oklahoma  0000001
    ## 2 Oklahoma  0000002
    ## 3 Oklahoma  0000003
    ## 4 Oklahoma  0000004
    ## 5 Oklahoma  0000005
    ## 6 Oklahoma  0000006

    q_out = dbGetQuery(conn, statement = "select `Iteration Code` from Iterations")
    head(q_out)

    ##   Iteration Code
    ## 1            001
    ## 2            002
    ## 3            003
    ## 4            004
    ## 5            005
    ## 6            006

And here are a few queries involving multiple tables.

    q_out = dbGetQuery(conn, statement = "
        select g.REGION, g.DIVISION, g.STATE, g.COUNTY, p.*
        from Geo_050 g, PCT1 p
        where g.FILEID == p.FILEID
        and g.LOGRECNO == p.LOGRECNO
    ")
    head(q_out, 3)

    ##   REGION DIVISION STATE COUNTY FILEID STUSAB CHARITER CIFSN LOGRECNO PCT0010001
    ## 1      3        7    40    001  SF2ST     OK      001    01  0000015      22683
    ## 2      3        7    40    001  SF2ST     OK      002    01  0000015       9757
    ## 3      3        7    40    001  SF2ST     OK      003    01  0000015      12051

    q_out = dbGetQuery(conn, statement = "
        select g.REGION, g.DIVISION, g.STATE, g.COUNTY, p.CHARITER, p.LOGRECNO,
            p.PCT0010001, it.Iterations
        from Geo_050 g, PCT1 p, Iterations it
        where g.FILEID == p.FILEID
        and g.LOGRECNO == p.LOGRECNO
        and p.CHARITER == it.`Iteration Code`
    ")
    head(q_out, 3)

    ##   REGION DIVISION STATE COUNTY CHARITER LOGRECNO PCT0010001
    ## 1      3        7    40    001      001  0000015      22683
    ## 2      3        7    40    001      002  0000015       9757
    ## 3      3        7    40    001      003  0000015      12051
    ##                                                   Iterations
    ## 1                                           Total Population
    ## 2                                                White alone
    ## 3 White alone or in combination with one or more other races
