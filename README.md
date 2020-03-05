# Overview
The purpose of the `sfreader` package is to read Summary Files from the
decennial census and write the contents to a relational database (such as
SQLite) which can be easily queried. Because Summary Files each have subtly
different formats, each requires its own reader to be written.

This is a personal project of the author, and is not endorsed in any way
by the U.S. Census Bureau. The package is also currently under heavy
construction, and should not be depended upon in any serius way.

To install the package:
``` {r}
devtools::install_github("andrewraim/sfreader")
```
