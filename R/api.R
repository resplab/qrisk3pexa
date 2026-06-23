# Mapping: QRISK3 internal column names  ->  our API variable names
.col_map <- c(
  ID                = "patid",
  gender            = "gender",
  age               = "age",
  b_AF              = "atrial_fibrillation",
  b_atypicalantipsy = "atypical_antipsy",
  b_corticosteroids = "regular_steroid_tablets",
  b_impotence2      = "erectile_disfunction",
  b_migraine        = "migraine",
  b_ra              = "rheumatoid_arthritis",
  b_renal           = "chronic_kidney_disease",
  b_semi            = "severe_mental_illness",
  b_sle             = "systemic_lupus_erythematosis",
  b_treatedhyp      = "blood_pressure_treatment",
  b_type1           = "diabetes1",
  b_type2           = "diabetes2",
  weight            = "weight",
  height            = "height",
  ethrisk           = "ethiniciy",
  fh_cvd            = "heart_attack_relative",
  rati              = "cholesterol_HDL_ratio",
  sbp               = "systolic_blood_pressure",
  sbps5             = "std_systolic_blood_pressure",
  smoke_cat         = "smoke",
  town              = "townsend"
)

# API variable names (derived from the map — single source of truth)
.var_names <- unname(.col_map)


#' Run the QRISK3 model
#'
#' @param model_input Named list or data frame of patient inputs.
#' @return Data frame with QRISK3 risk score columns.
#' @export
model_run <- function(model_input = NULL, hist = FALSE) {

  # Reject any key not in the known variable list
  unknown <- setdiff(names(model_input), .var_names)
  if (length(unknown) > 0) {
    stop("Unknown input variable(s): ", paste(unknown, collapse = ", "))
  }

  # Convert named list/data frame to data frame
  df <- as.data.frame(model_input, stringsAsFactors = FALSE)

  # Call QRISK3_2017 — each argument after 'data' is the matching column name string
  result <- QRISK3::QRISK3_2017(
    data                         = df,
    patid                        = "patid",
    gender                       = "gender",
    age                          = "age",
    atrial_fibrillation          = "atrial_fibrillation",
    atypical_antipsy             = "atypical_antipsy",
    regular_steroid_tablets      = "regular_steroid_tablets",
    erectile_disfunction         = "erectile_disfunction",
    migraine                     = "migraine",
    rheumatoid_arthritis         = "rheumatoid_arthritis",
    chronic_kidney_disease       = "chronic_kidney_disease",
    severe_mental_illness        = "severe_mental_illness",
    systemic_lupus_erythematosis = "systemic_lupus_erythematosis",
    blood_pressure_treatment     = "blood_pressure_treatment",
    diabetes1                    = "diabetes1",
    diabetes2                    = "diabetes2",
    weight                       = "weight",
    height                       = "height",
    ethiniciy                    = "ethiniciy",
    heart_attack_relative        = "heart_attack_relative",
    cholesterol_HDL_ratio        = "cholesterol_HDL_ratio",
    systolic_blood_pressure      = "systolic_blood_pressure",
    std_systolic_blood_pressure  = "std_systolic_blood_pressure",
    smoke                        = "smoke",
    townsend                     = "townsend"
  )

  if (hist) {
    hist(result$QRISK3_2017,
         main = "Distribution of predicted 10-year CVD risk",
         xlab = "QRISK3 score (%)",
         col  = "steelblue",
         border = "white")
  }

  return(result)
}


#' Get sample input for the QRISK3 model
#'
#' Returns the QRISK3_2019_test dataset with columns renamed to API variable
#' names, so that model_run(get_sample_input()) works directly.
#'
#' @param n Optional positive integer. If supplied, returns the top n rows;
#'   otherwise returns the full dataset.
#' @return Data frame of sample patient inputs.
#' @export
get_sample_input <- function(n = NULL) {

  # Load the internal test dataset from the QRISK3 package
  e <- new.env(parent = emptyenv())
  data("QRISK3_2019_test", package = "QRISK3", envir = e)
  df <- e$QRISK3_2019_test

  # Keep only columns that have an API mapping, then rename them
  df <- df[, names(.col_map), drop = FALSE]
  names(df) <- .col_map[names(df)]

  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1L || n < 1L) {
      stop("n must be a single positive integer.", call. = FALSE)
    }
    df <- head(df, n)
  }

  df
}


#' Get the default input for the QRISK3 model
#'
#' Returns a single-row data frame representing a typical patient profile with
#' no elevated risk factors — useful as a baseline for exploring the model.
#'
#' @return Named list of default input values.
#' @export
get_default_input <- function() {
  list(
    patid                        = 1L,
    gender                       = 1L,
    age                          = 50,
    atrial_fibrillation          = 0L,
    atypical_antipsy             = 0L,
    regular_steroid_tablets      = 0L,
    erectile_disfunction         = 0L,
    migraine                     = 0L,
    rheumatoid_arthritis         = 0L,
    chronic_kidney_disease       = 0L,
    severe_mental_illness        = 0L,
    systemic_lupus_erythematosis = 0L,
    blood_pressure_treatment     = 0L,
    diabetes1                    = 0L,
    diabetes2                    = 0L,
    weight                       = 80,
    height                       = 175,
    ethiniciy                    = 1L,
    heart_attack_relative        = 0L,
    cholesterol_HDL_ratio        = 4.0,
    systolic_blood_pressure      = 120,
    std_systolic_blood_pressure  = 0,
    smoke                        = 0L,
    townsend                     = 0
  )
}
