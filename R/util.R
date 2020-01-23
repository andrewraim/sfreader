#' @export
printf = function(msg, ...)
{
        cat(sprintf(msg, ...))
}

#' @export
logger = function(msg, ...)
{
        sys.time = as.character(Sys.time())
        cat(sys.time, "-", sprintf(msg, ...))
}
