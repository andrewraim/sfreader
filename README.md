# Overview
One of the formats used to disseminate data from the decennial census and the
American Community Survey (ACS) is the Summary File. These can be obtained from
the U.S. Census Bureau website. Summary Files contain a comprehensive amount of
data which can be used to produce many tabulations of interest. They can be
especially useful in computing environments which do not have access to the
internet; e.g., so that the Census Bureau data API cannot be accessed.
However, the format of the files which constitute a Summary File makes their
use somewhat more involved than simpler formats such as CSV files.
Furthermore, the format may vary across different Summary Files.

The purpose of the `sfreader` package is to help users extract information from
the files within a Summary File. Once the information is extracted, users will
be able to refer to Summary File documentation to interpret the data and use
data manipulation tools (such as the Tidyverse) to query or produce customized
datasets for applications.

This project is an initiative of the authors, and is not endorsed in any way by
the U.S. Census Bureau. Please send comments or questions to the authors. The
package is also currently under heavy construction, and should not be depended
upon in any serious way.

As of this writing, only 2010 SF2 is supported.


# Installation
To install from Github, obtain the `devtools` package and run the
following in R.

```r
devtools::install_github("andrewraim/sfreader")
```

# Examples
Some examples are provided in `inst/examples`.

