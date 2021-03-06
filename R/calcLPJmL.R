#' @title calcLPJmL
#' @description Handle LPJmL data and its time behaviour (averaging, approximation, harmonizing to baseline)
#' 
#' @param version Switch between LPJmL4 and LPJmL4
#' @param climatetype Switch between different climate scenarios (default: "CRU_4")
#' @param subtype Switch between different lpjml input as specified in readLPJmL
#' @param selectyears defaults to all years available
#' @param time average, spline or raw (default)
#' @param averaging_range just specify for time=="average": number of time steps to average
#' @param dof             just specify for time=="spline": degrees of freedom
#' @param harmonize_baseline FALSE (default) nothing happens, if a baseline is specified here data is harmonized to that baseline (from ref_year on)
#' @param ref_year just specify for harmonize_baseline != FALSE : Reference year
#' @param limited  just specify for harmonize_baseline != FALSE : if TRUE limited approached is used
#' @param hard_cut just specify for harmonize_baseline != FALSE : use hard cut instead of multiplicative factor
#' 
#' @return List of magpie objects with results on cellular level, weight, unit and description.
#' @author Kristine Karstens
#' @seealso
#' \code{\link{readLPJmL}}
#' @examples
#' 
#' \dontrun{ 
#' calcOutput("LPJmL", version="LPJmL4", climatetype="CRU_4", subtype="soilc", aggregate=FALSE)
#' }

calcLPJmL <- function(version="LPJmL4", climatetype="CRU_4", subtype="soilc", time="raw", averaging_range=NULL, dof=NULL, 
                      harmonize_baseline=FALSE, ref_year="y2015", limited=TRUE, hard_cut=FALSE, selectyears="all"){

  readin_name <- paste0(version,":",climatetype,".",subtype)  
  LPJmL_input <- readSource("LPJmlCarbon", subtype=readin_name, convert="onlycorrect")
  
  if(time=="average"){
    
    LPJmL_input <- toolTimeAverage(LPJmL_input, averaging_range = averaging_range)
    
  } else if(time=="spline"){
    
    LPJmL_input <- toolTimeSpline(LPJmL_input, dof = dof)
    
  } else if(time!="raw"){
    
    stop("Time argument not supported!")
  }
  
  if(harmonize_baseline!=FALSE){
    
    #read in historical data for subtype
    Baseline    <- calcOutput("LPJmL", version=version, climatetype=harmonize_baseline, subtype=subtype, time=time, 
                              averaging_range=averaging_range, dof=dof, harmonize_baseline=FALSE)
    #use 
    LPJmL_input <- toolHarmonize2Baseline(LPJmL_input, Baseline,  ref_year=ref_year, limited=limited, hard_cut=hard_cut)
  }
  
  if(selectyears!=all){
    years       <- sort(findset(selectyears,noset = "original"))
    LPJml_input <- LPJml_input[,years,]
  } 
  
  # unit table for subtypes
  unites <- c(soilc           = "tC/ha",
             soilc_layer     = "tC/ha",
             litc            = "tC/ha",
             vegc            = "tC/ha",
             alitfallc       = "tC/ha",
             alitfalln       = "tN/ha",
             harvest         = "tDM/ha",
             irrig           = "?",
             sdate           = "day?",
             hdate           = "day?",
             transpiration   = "?",
             discharge       = "?",
             runoff          = "?",
             evaporation     = "?",
             vegc_grass      = "tC/ha",
             litc_grass      = "tC/ha",
             soilc_grass     = "tC/ha"
  )
  
  unit <- toolSubtypeSelect(subtype,units)
  
  return(list(
    x=LPJml_input,
    weight=NULL,
    unit=unit, 
    description=paste0("Carbon output from LPJmL (",subtype,") for ", version, "and", climatetype, "."),
    isocountries=FALSE))

}
  