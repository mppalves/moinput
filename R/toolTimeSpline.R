#' toolTimeSpline
#'
#' Creating a spline for a time series using given degrees of freedom
#' 
#' @param x magclass object that should be interpolated/approximated with a spline
#' @param dof degrees of freedom per 100 years (similiar to an average range), is a proxy for the smoothness of the spline
#' 
#' @return approximated data in magclass format
#' @author Kristine Karstens
#'
#' @importFrom stats smooth.spline
#' @export

toolTimeSpline <- function(x, dof=NULL){
  
  if(!is.magpie(x)) stop("Input is not a MAgPIE object, x has to be a MAgPIE object!")
  
  years    <- getYears(x, as.integer = TRUE)
  timespan <- years[length(years)] - years[1]
  
  if(is.null(dof)){
    dof <- timespan*5/100
  } else if(dof<1) {
    warning(paste("Invalid choice of dof. Value",dof,"is not allowed! Value is set to 5 dof per 100 years instead!"))
    dof <- timespan*5/100
  } else {
    dof <- timespan*dof/100
  }
  
  # check dofs << length(years)
  if(dof > timespan*30/100) warning("Choice of degrees of freedom will create rather interpolation than an approximation.")
  
  out      <- x
  class(x) <- NULL
  
  # Loop over all dimension except time to fill in data with spline approximations/interpolations
  for (d1 in 1:dim(x)[1]) {
    for (d3 in 1:dim(x)[3]) {
      out[d1,,d3]     <- smooth.spline(x[d1,,d3],df=dof, control.spar=list(high=2))$y 
    }
  }

  return(out)
}