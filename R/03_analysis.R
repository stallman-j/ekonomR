#' Function for outputting a linear model
#' @description Outputs a linear model from an outvar and covariates within a data frame, see https://gis.stackexchange.com/questions/403811/linear-regression-analysis-in-r
#' @param df data frame the vars come from
#' @param outvar string, output var
#' @param covars of form c("covar1", "covar2", etc) all covariates
#' @return lm model
#
lm_model <- function(df,
                     outvar,
                     covars,
                     ...){
  form <- paste(outvar,paste(covars,collapse = " + "), sep = " ~ ")

  f<-  as.formula(form)

  lm <- lm(f,
              data = df,
           ...)

  return(lm)
}

#' Get Regression Equation
#' @param outcome_var a string vector with the outcome variable name
#' @param regressor_vars a character vector with all the regressors (not fixed effects) variable names
#' @param fe_vars if fixed effects desired, a character vector of the variable names to take fixed effects of.
#' @returns A regression formula that can either be used as an input to the lm function or fixest::feols if fe_vars is not null
#' @export

reg_equation <- function(outcome_var = "lge_15",
                         regressor_vars = c("gdp_pc","tfr"),
                         fe_vars        = NULL){

  reg_string <- paste(outcome_var, paste(regressor_vars, collapse = " + "), sep = " ~ ")

  if (!is.null(fe_vars)){
    reg_form <- paste(reg_string,paste(fe_vars,collapse = " + "), sep = "|") %>% as.formula()
  } else

    reg_form   <- reg_string %>% as.formula()

  return(reg_form)


}

#' Function for getting robust ses, requires sandwich package
#' @param lm_model the lm model, output of lm_model or just a function arrived at via lm()
#' @param type type of SEs, for stata robust it's "HC1"
#' @return lm_robust_se robust SEs

  lm_robust_se <- function(lm_model,
                           type = "HC1") {
    cov  <- sandwich::vcovHC(lm_model,
                   type = type)

    lm_model_se <- sqrt(diag(cov))

    return(lm_model_se)
  }


# inverse logit to convert log-odds back to probabilities----

  # inv.logit <- function(logit){
  #   odds <- exp(logit)
  #   prob <- odds / (1 + odds)
  #   return(prob)
  # }

