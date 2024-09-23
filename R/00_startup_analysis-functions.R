# Analysis Functions


#' Function for outputting an LM model
#' @param df data frame the vars come from
#' @param outvar string, output var
#' @param covars of form c("covar1", "covar2", etc) all covariates
#' @return lm model 
#   # https://gis.stackexchange.com/questions/403811/linear-regression-analysis-in-r

lm_model <- function(df,
                     outvar,
                     covars,
                     ...){
  form <- paste(outvar,paste(covars,collapse = " + "), sep = " ~ ")
  
  f<-  as.formula(form)
  
  lm <- lm(f,
              data = df)
  
  return(lm)
}

#' Function for getting robust ses, requires sandwich package
#' @param lm_model the lm model you got
#' @param type type of SEs, for stata robust it's "HC1"
#' @return lm_robust_se robust SEs

  lm_robust_se <- function(lm_model,
                           type = "HC1") {
    cov  <- vcovHC(lm_model,
                   type = type)
    
    lm_model_se <- sqrt(diag(cov))
    
    return(lm_model_se)
  }
  
  
# inverse logit to convert log-odds back to probabilities----
  
  inv.logit <- function(logit){
    odds <- exp(logit)
    prob <- odds / (1 + odds)
    return(prob)
  }
  
  