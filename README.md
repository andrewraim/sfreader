# Overview
Releases of tabulations from the decennial census or American Community Survey
(ACS) are organized into Summary Files. Data from Summary Files can be obtained
from the U.S. Census Bureau FTP site. These data contain many tabulations of
interest and may be especially useful in secure computing environments which do
not have access to the internet; e.g., where Census Bureau data API cannot be
accessed. However, data obtained from the FTP site are distributed in a format
which is somewhat difficult to navigate. The format may vary across different
Summary Files.

The purpose of the `sfreader` package is to help users extract information from
the files within a Summary File. Once the information is extracted, users will
be able to refer to Summary File documentation to interpret the data and use
data manipulation tools (such as the Tidyverse) to query or produce customized
datasets for applications. As of this writing, only 2010 SF2 is supported.

The authors - not the U.S. Census Bureau - are responsible for this project and
any views expressed herein. Comments or questions should be directed to the
authors.

# Installation
To install from Github, obtain the `devtools` package and run the
following in R.

```r
devtools::install_github("andrewraim/sfreader")
```

