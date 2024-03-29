% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sf2_2010.R
\docType{data}
\name{sf2_2010_fields}
\alias{sf2_2010_fields}
\title{SF2 2010 Fields}
\format{
A data frame with 1575 rows and 6 columns:
\describe{
  \item{SEGMENT}{Segment associated with the variable.}
  \item{POSITION}{Position of the variable in the file for the given segment.}
  \item{FIELD}{Name of the variable.}
  \item{PARENT_FIELD}{Name of this variable's parent variable.}
  \item{TABLE}{Name of the logical table associated with this variable.}
  \item{NAME}{Description of the variable.}
  \item{DESCRIPTION}{Fully qualified name of the variable based on table hierarchy.}
}
}
\source{
\url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
}
\usage{
sf2_2010_fields
}
\description{
SF2 2010 Fields
}
\details{
A summary file contains a number of "logical" tables which are partitioned
into 11 types of data files; each file type contains a segment of containing
the variables of one or more of the logical tables. Variables within a table
are defined as a hierarchical structure where each may be contain one or more
child variables.

This dataset enumerates the variables contained within each segment, so that
the column names can be overlaid onto the data as headers.

This dataset also provides a mapping from each variable to the logical table
to which it belongs. An value of \code{HEAD} indicates that the variable is
part of the header and does not belong to a logical table.

The hierarchical structure of each table may be accessed via the
\code{PARENT_FIELD} variable. This variable specifies the parent in the
hierarchy, or is \code{NA} if it at the top level of the hierarchy.
}
\keyword{datasets}
