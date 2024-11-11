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

#' modelsummary_reg_default
#' @description modelsummary_reg_default is a workflow wrapper around modelsummary::modelsummary() and tinytable::save_tt(). It takes in a list of regression variables and a dataframe, turns the list of regression variables into regression models, and outputs a modelsummary table with reasonable defaults for these regressions.
#' It currently supports using fixest::feols with fixed effects (in which case it clusters standard errors by the fixed effects categories); as well as lm() for regression equations which do not have fixed effects variables inputted. It tries to cleverly add in dependent variable means and fixed effect rows if fixed effects are included.
#' See the vignette [Fixed Effects Estimation](https://stallman-j.github.io/ekonomR/vignettes/fixed-effects-estimation) for how this function comes together and a couple examples of use.
#' @param reg_vars_list requires a list where each element of the list is also a list.
#' @param my_title title for your table
#' @param table_notes notes to put in your table
#' @param cov_labels labels for the covariates. if you input this you need to make sure it's the right length for the covariates you're including
#' @param fe_names defaults to NULL, in which case we take the column names of the variables inputted as FE vars. could instead give a character vector e.g. c("Year FE","Country FE") to put into the modelsummary output. You need to make sure that this character vector is in the order that this function will pick out, though, so I recommend running it through first with fe_names = NULL to see that the output accords with what you think, and then adjusting.
#' @param depvar_means default of NULL takes the mean of the dependent variable for each column, rounded to 2 significant digits, with missing values removed before the mean is calculated. If you want something different, input a numeric vector of the means that you want for each column of your regression. If not NULL, this vector therefore needs to have the same number of elements as reg_vars_list does.
#' @param format defaults to "latex", in modelsummary
#' @param stars defaults to FALSE, from modelsummary
#' @param escape defaults to FALSE, in modelsummary so that output is less buggy
#' @param gof_omit goodness of fit statistics to ignore, defaults to keeping mostly the R2 and Adj R2
#' @param fmt format of the final table, defaults to 4 decimal points, from modelsummary
#' @param print_models default is TRUE, whether you want to print the list of models with output to the console
#' @param out_path defaults to here::here("output","01_tables"), the place to send table output if you're saving it. will create the folder if it doesn't exist already
#' @param output_filename character vector, name for output filename. defaults to "regression_table"
#' @param export_output defaults to TRUE, in which case it saves a .docx and a .tex file into the file path given by file.path(out_path,paste0(output_filename,".tex")) and file.path(out_path,paste0(output_filename,".docx"))
#' @param ... additional options to put into modelsummary
#'
#' @returns a modelsummary object
#' @export
#'
#' @examples
#' data(ghg_pop_gdp)
#' reg_1_vars <- list(outvar = "gcb_ghg_territorial_pc",
#' regvars = c("gdp000_pc","I(gdp000_pc^2)","I(gdp000_pc^3)"),
#' fevars  = NULL)
#' reg_2_vars <- list(outvar = "gcb_ghg_territorial_pc",
#'                    regvars = c("gdp000_pc","I(gdp000_pc^2)","I(gdp000_pc^3)"),
#'                    fevars = "year"))
#' reg_vars_list <- list(reg_1_vars,reg_2_vars)
#' # default output
#' modelsummary_reg_default(reg_vars_list, data = ghg_pop_gdp)
#' # save and adjust ex post, so don't export
#' my_table <- modelsummary_reg_default(reg_vars_list, data = ghg_pop_gdp, export_output = FALSE)
#' my_table <- my_table %>% tinytable::group_tt(j = list("GHGpc" =2:3))
#'if (!dir.exists(here::here("output","01_tables"))) dir.create(here::here("output","01_tables"), recursive = TRUE)
#' tinytable::save_tt(my_table, output = here::here("output","01_tables","fixed_effects_table.tex"), overwrite = TRUE)
#'
modelsummary_reg_default <- function(reg_vars_list,
                                     data,
                                     my_title = "My regression table \\label{tab:reg-table}",
                                     table_notes = c("Robust standard errors given in parentheses."),
                                     cov_labels = FALSE,
                                     fe_names = NULL,
                                     depvar_means = NULL,
                                     format = "latex",
                                     stars = FALSE,
                                     escape = FALSE,
                                     gof_omit = "AIC|BIC|RMSE|Log.Lik|Std.Errors|FE:|Adj.|F",
                                     fmt  = 4,
                                     out_path = here::here("output","01_tables"),
                                     output_filename = "regression_table",
                                     export_output = TRUE,
                                     print_models = TRUE,
                                     ...
                                 ){

  # len is the number of regressions we run. It is getting used a lot so we just set the number

  len <- length(reg_vars_list)

  # create the lists we'll need to populate
  reg_eqs_list         <- vector(mode = "list", length = len)
  vcov_list            <- vector(mode = "list", length = len)
  unique_varnames_list <- vector(mode = "list", length = len)
  models_list          <- vector(mode = "list", length = len)
  unique_fes_list      <- vector(mode = "list", length = len)

   # make regression formulas
  for (i in 1:len) {
    reg_eqs_list[[i]] <- ekonomR::reg_equation(outcome_var = reg_vars_list[[i]]$outvar,
                                               regressor_vars = reg_vars_list[[i]]$regvars,
                                               fe_vars     = reg_vars_list[[i]]$fevars)
  }

  # put standard errors in a list
  for (i in 1:len) {
    vcov_list[[i]] <- ekonomR::cluster_formula(reg_eqs_list[[i]], verbose = FALSE)
  }


  # generate models
  for (i in 1:len) {

    # if there's no fe_vars in reg_vars_list, then use lm(). If there is, use fixest::feols()
    if (is.null(reg_vars_list[[i]]$fevars)) {
      models_list[[i]] <- lm(reg_eqs_list[[i]],
                             data = data)
    } else {
      models_list[[i]] <- fixest::feols(reg_eqs_list[[i]],
                                        vcov = vcov_list[[i]],
                                        data = data)
    }

    # get the number of unique regressor vars
    unique_varnames_list[[i]] <- unique(reg_vars_list[[i]]$regvars)

    # get the number of unique FE vars
    unique_fes_list[[i]] <- unique(reg_vars_list[[i]]$fevars)

  }


  if (print_models == TRUE) {print(lapply(models_list,summary))}

  length_unique_varnames <- length(unique(unlist(unique_varnames_list)))
  unique_fes             <- unique(unlist(unique_fes_list))

  # determine the rows to add into the table

  # if unique_fes comes up NULL, none of the regressions have fixed effects,
  # so just add the depvar means

  if (is.null(unique_fes)) {

    col_1 <- data.frame("term" = c("Mean"))
    other_cols <- matrix(NA,
                         nrow = nrow(col_1),
                         ncol = len) %>% as.data.frame()
    rows <- cbind(col_1,other_cols)

    for (i in 1:len){

      if (is.null(depvar_means)) {

        # if the thing listed as "outvar" is not actually a variable in the dataset, create a temp var and take its mean

        if (!(reg_vars_list[[i]]$outvar) %in% names(data)) { # if there's a formula given as a character, try to evaluate it

          message(paste0(reg_vars_list[[i]]$outvar, " is not a column variable in your data. I'm going to try to get the dependent variable mean anyways and it might work, but you should check that it went through right."))

          temp_data <- data %>%
                     dplyr::mutate(temp_outvar = eval(str2lang(reg_vars_list[[i]]$outvar)))

          rows[1,i+1] <- round(mean(temp_data$temp_outvar, na.rm = TRUE),2)

        } else { # the thing listed as "outvar" is actually a variable in the dataset, then take its mean

        rows[1,i+1] <- round(mean(data[[reg_vars_list[[i]]$outvar]], na.rm = TRUE),2)
        }

      } else {
        rows[1,i+1] <- depvar_means[i]
      }

    }

    attr(rows, 'position') <- 2*n_total_regvars+6


  } else { # end if is.null(unique_fes) i.e. the reg table has no FEs, just add the depvar means

    # now assuming that there are regressions with fixed effects

# add attribute rows for depvar means and fixed effects

  # determine the number of rows to add by getting the first column of this "rows" data frame
  # it'll look like

    # |Mean     |
    # |year FEs |
    # |iso3c FEs|
    # |...      |

  if (!is.null(fe_names)) { # if fe_names were given by user, replace here
    col_1 <- data.frame("term" = c("Mean",fe_names))
  } else {
    col_1 <- data.frame("term" = c("Mean",paste0(unique_fes," FE")))

  }

  other_cols <- matrix(NA,
                       nrow = nrow(col_1),
                       ncol = len) %>% as.data.frame()

  rows <- cbind(col_1,other_cols)

  rows
  # add on a column for each regression equation
  for (i in 1:len) {

    # test if the ith reg_vars_list has a fe_vars in the unique_fes
    for (j in 1:length(unique_fes)) {

      # fill in the depvar means with either the default value or the thing the user gave
      if (is.null(depvar_means)) {

        # if the thing listed as "outvar" is not actually a variable in the dataset, create a temp var and take its mean

        if (!(reg_vars_list[[i]]$outvar) %in% names(data)) { # if there's a formula given as a character, try to evaluate it

          message(paste0(reg_vars_list[[i]]$outvar, " is not a column variable in your data. I'm going to try to get the dependent variable mean anyways and it might work, but you should check that it went through right."))

          temp_data <- data %>%
            dplyr::mutate(temp_outvar = eval(str2lang(reg_vars_list[[i]]$outvar)))

          rows[1,i+1] <- round(mean(temp_data$temp_outvar, na.rm = TRUE),2)

        } else { # the thing listed as "outvar" is actually a variable in the dataset, then take its mean

          rows[1,i+1] <- round(mean(data[[reg_vars_list[[i]]$outvar]], na.rm = TRUE),2)
        }

        } else {
        rows[1,i+1] <- depvar_means[i]
      }

      # if the jth fe is in the list of fevars for this regression, list as a "Y"
      if (unique_fes[j] %in% reg_vars_list[[i]]$fevars) {
      rows[j+1,i+1] <- "Y"
      } else {
        rows[j+1,i+1] <- "N"
      }
    }

  }

  # set the position of the rows. we want a row for each of the mean and the FEs
  attr(rows, 'position') <- 2*n_total_regvars+3+c(1:(length(unique_fes)+1))

  }


  my_table <- modelsummary::modelsummary(models_list,
                                         stars = stars,
                                         vcov = vcov_list,
                                         fmt  = fmt,
                                         coef_rename = cov_labels,
                                         title = my_title,
                                         format = format,
                                         add_rows = rows,
                                         gof_omit = gof_omit,
                                         escape = escape,
                                         notes = table_notes,
                                         ...
  )

  if (export_output == TRUE) {

    # generate output folder if it doesn't already exist
  if (!dir.exists(out_path)) {
    message(paste0("Created output folder ", out_path, " which is where you'll find your regression output."))
    dir.create(out_path, recursive = TRUE)
  }

    message(paste0("Saving regression output to ", out_path, " ."))

  tinytable::save_tt(my_table,
                     output = file.path(out_path,paste0(output_filename,".tex")),
                     overwrite = TRUE)

  tinytable::save_tt(my_table,
                     output = file.path(out_path,paste0(output_filename,".docx")),
                     overwrite = TRUE)

  }

  return(my_table)
}

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

