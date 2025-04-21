#' Calculate rent Proposal
#'
#' \code{calculate_rent_proposal} takes in a BLS file and some start and end dates, then a starting rent, and suggests a proposed rent based on the increase in CPI from the start date to ending date.
#' @author jstallman
#' @param bls_xlsx_file full filepath to the xlsx file downloaded from the BLS
#' @param start_month character, three-letter month as given in BLS. Default "Jun"
#' @param start_year character, year of start date. Default "2021"
#' @param end_month character, three-letter month as given by BLS, e.g. "Mar"
#' @param end_year character, year of end date. Default is "2025"
#' @param start_rent numeric, starting rent. Default is 1500
#' @param skip_val numeric, number of rows to skip in the BLS xlsx data. Default 10 worked for the ones I downloaded
#' @param ... additional parameters to put into the readxl::read_xlsx() call for the BLS file
#' @export
#' @returns suggested proposed rent based on the inflation calculated.


calculate_rent_proposal <- function(bls_xlsx_file,
                                    start_month = "Jun",
                                    start_year  = "2021",
                                    end_month   = "Mar",
                                    end_year    = "2025",
                                    start_rent  = 1500,
                                    skip_val    = 10, # change if something goes wrong
                                    ...){

  data <- readxl::read_xlsx(path = bls_xlsx_file,
                            skip = skip_val,
                            col_names = TRUE,
                            ...
  )%>%
    tidyr::pivot_longer(cols = -c(Year),
                        names_to = "month",
                        values_to = "CPI") %>%
    dplyr::rename(year = Year)

  start_cpi <- data %>%
    dplyr::filter(month == start_month,
                  year  == start_year) %>%
    dplyr::pull()

  end_cpi <- data %>%
    dplyr::filter(month == end_month,
                  year  == end_year) %>%
    dplyr::pull()

  inflation <- (end_cpi - start_cpi)/start_cpi

  rent_proposed <- start_rent + start_rent*inflation

  print(paste0("Inflation from ",start_month, " " ,start_year, " to ", end_month, " ", end_year, " was ",round(inflation,3)*100,"% according to the BLS CPI that you inputted. For a starting rent of $",start_rent," you might propose a rent of $",round(rent_proposed,3),"."))
  return(rent_proposed)
}
