#' Stargazer sumstats, good defaults for stargazer
#'
#' @param data dataset you would like summarized. Assumed to be the case that all the columns you want are included
#' @param type output type for stargazer
#' @param style input to starza
#' @param summary TRUE, whether to make the thing sumstats
#' @param covariate.labels default NULL in which case you use varnames
#' @param summary.stat which sum stats to display
#' @param digits number of significant digits, default is 2
#' @param out_path output path, default here::here("output","01_tables")
#' @param output_filename filename for the output, default "summary_stats.tex"
#' @param title Title of the table, default "summary statistics"
#' @param label default label for the table
#' @param float whether to float in latex, default FALSE so that tabular environment is removed
#'
#' @returns output tables in both latex and text format, both to console and in the output_path location, with nice defaults
stargazer_sumstats <- function(data,
                               type = "latex",
                               style = "qje",
                               summary = TRUE,
                               covariate.labels = NULL,
                               summary.stat = c("n","min","mean","median","max","sd"),
                               digits = 2,
                               out_path = here::here("output","01_tables"),
                               output_filename = "summary_stats.tex",
                               title = "Summary Statistics",
                               label = "tab:summary_stats",
                               float = FALSE) {

  print("Currently in production")
}

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

#' cluster_formula: gives the formula for clustering standard errors based on what fixed effects variables you tell it to keep, for use in the argument of modelsummary
#'
#' @param fe_vars default NULL, a character vector of the fixed effects you're using
#' @param reg_eq additionally, a regression equation of the format that the fixest package will use, which is to say of the type y ~ x | year + country. In this case, fixest_cluster_formula will pick out that the fe_vars are c("year","country") so that modelsummary or feols can cluster appropriately
#' @param verbose default = TRUE, will tell you if it thinks you inputted something wrong and what the defaults are
#' @returns a formula with the clustered variables that you can include in the vcov argument of modelsummary to get you clustered standard errors. If it thinks you've inputted a regression equation without fixed effects, it's going to try to default to heteroskedasticity robust standard errors with "HC1"
#' @export
#'
cluster_formula <- function(reg_eq  = NULL,
                            fe_vars = NULL,
                            verbose = TRUE
                            ) {

if (verbose == FALSE) {
  if (class(fe_vars) == "formula") {
    reg_eq = fe_vars
    fe_vars = NULL
  }

  if (class(reg_eq) == "character") {
    fe_vars = reg_eq
    reg_eq = NULL
  }

  if (is.null(fe_vars) & is.null(reg_eq)) stop({message("Error: you don't have any arguments I can use, input a valid value for either fe_vars, e.g. fe_vars = c('year') or a regression formula e.g. 'y ~ x | year' ")})

  if (!is.null(fe_vars) & !is.null(reg_eq)) stop({message("Error: just pick one of fe_vars, e.g. fe_vars = c('year') or a regression formula e.g. 'y ~ x | year'. Not both, please. ")})

  if (!is.null(fe_vars) & is.null(reg_eq)) {
    # pull out the fe_vars and make them into a little formula
    cluster_formula <- paste0("~", paste(fe_vars, collapse = " + ")) %>% as.formula
  }

  if (is.null(fe_vars) & !is.null(reg_eq)) {

    # split the formula back to characters
    char <- as.character(reg_eq)

    # the third element of this is the regressor vars. Now split the string at the | sign. We need to escape the | (which means just "or" in regular expressions) with the double backslash. Pull out the first element of the output

    extract <- stringr::str_split(char[3], "\\|")[[1]]

    # the first element of extract is going to be the original regressors. The second will be the cluster vars. the third if it exists is the IV vars.

    if (is.na(extract[2])) {

      cluster_formula <- "HC1"


    } else {
    cluster_formula <- paste0("~", paste(extract[2], collapse = " + ")) %>% as.formula()

  }
  }
} else { # end if verbose == FALSE, ie if verbose == TRUE
  if (class(fe_vars) == "formula") {
    reg_eq = fe_vars
    fe_vars = NULL

    message("I think what you did was input something like cluster_formula(fe_vars = my_reg_eq). So I switched that around, but you should double-check your output.")
  }

  if (class(reg_eq) == "character") {
    fe_vars = reg_eq
    reg_eq = NULL
    message("I think what you did was input something like cluster_formula(reg_eq = my_fe_vars) or cluster_formula(my_fe_vars). But if you don't define the argument, that gets inputted as cluster_formula(reg_eq = my_fe_vars). I switched that around and did what I could, but you should double-check your output makes sense.")
  }

  if (is.null(fe_vars) & is.null(reg_eq)) stop({message("Error: you don't have any arguments I can use, input a valid value for either fe_vars, e.g. fe_vars = c('year') or a regression formula e.g. 'y ~ x | year' ")})

  if (!is.null(fe_vars) & !is.null(reg_eq)) stop({message("Error: just pick one of fe_vars, e.g. fe_vars = c('year') or a regression formula e.g. 'y ~ x | year'. Not both, please. ")})

  if (!is.null(fe_vars) & is.null(reg_eq)) {
    # pull out the fe_vars and make them into a little formula
    cluster_formula <- paste0("~", paste(fe_vars, collapse = " + ")) %>% as.formula
  }

  if (is.null(fe_vars) & !is.null(reg_eq)) {

    # split the formula back to characters
    char <- as.character(reg_eq)

    # the third element of this is the regressor vars. Now split the string at the | sign. We need to escape the | (which means just "or" in regular expressions) with the double backslash. Pull out the first element of the output

    extract <- stringr::str_split(char[3], "\\|")[[1]]

    # the first element of extract is going to be the original regressors. The second will be the cluster vars. the third if it exists is the IV vars.

    if (is.na(extract[2])) {

      cluster_formula <- "HC1"

      {message("The regression formula you inputted either wasn't the correct format (it should be e.g. 'y ~ x | year') or didn't contain a variable to take fixed effects over (e.g. you wrote just y~x1 + x2 without a clustering variable). It's possible you want to show a regression without fixed effects. In case that's you, I'm setting this output to be 'HC1' so you'll get robust standard errors anyways if you put this output directly into feols or modelsummary.")}

    } else {
      cluster_formula <- paste0("~", paste(extract[2], collapse = " + ")) %>% as.formula()

    }
  }
} # end if verbose = TRUE

    return(cluster_formula)
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

