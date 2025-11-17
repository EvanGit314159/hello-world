# Case-Crossover Test Implementation in R
# 
# Case-crossover design is a within-person comparison method used to study
# the effect of transient exposures on the risk of acute events.
# It is particularly useful for studying rare events where each case serves
# as their own control.

# Function to perform case-crossover analysis
casecross_test <- function(case_exposure, control_exposures, method = "conditional") {
  #' Perform Case-Crossover Test
  #' 
  #' @param case_exposure Numeric vector of exposure values during case period
  #' @param control_exposures Numeric vector or matrix of exposure values during control periods
  #' @param method Character string specifying the analysis method ("conditional" or "matched")
  #' 
  #' @return A list containing test statistics and p-value
  #' 
  #' @examples
  #' # Example with single case
  #' case_exp <- 5
  #' control_exp <- c(2, 1, 3, 2)
  #' result <- casecross_test(case_exp, control_exp)
  #' print(result)
  
  # Validate inputs
  if (length(case_exposure) == 0 || length(control_exposures) == 0) {
    stop("Both case_exposure and control_exposures must have at least one value")
  }
  
  # For simple case-crossover, we use McNemar's test or conditional logistic regression
  # Here we implement a simple matched pairs approach
  
  # Ensure proper format for comparison
  # If case_exposure is a single value and control_exposures is a vector,
  # compare the case value against each control value
  if (length(case_exposure) == 1 && is.vector(control_exposures)) {
    # Single case, multiple control periods
    case_higher <- sum(case_exposure > control_exposures)
    control_higher <- sum(control_exposures > case_exposure)
  } else if (is.vector(case_exposure) && is.matrix(control_exposures)) {
    # Multiple cases, each row represents control periods for one case
    if (length(case_exposure) != nrow(control_exposures)) {
      stop("Number of cases must match number of rows in control_exposures")
    }
    # Compare each case against its control periods
    case_higher <- 0
    control_higher <- 0
    for (i in 1:length(case_exposure)) {
      case_higher <- case_higher + sum(case_exposure[i] > control_exposures[i, ])
      control_higher <- control_higher + sum(control_exposures[i, ] > case_exposure[i])
    }
  } else if (length(case_exposure) == length(control_exposures)) {
    # Paired comparison
    case_higher <- sum(case_exposure > control_exposures)
    control_higher <- sum(control_exposures > case_exposure)
  } else {
    stop("Incompatible dimensions for case_exposure and control_exposures")
  }
  
  # McNemar's test for paired data
  if (case_higher + control_higher > 0) {
    chi_sq <- (abs(case_higher - control_higher) - 1)^2 / (case_higher + control_higher)
    p_value <- pchisq(chi_sq, df = 1, lower.tail = FALSE)
    
    # Calculate odds ratio
    if (control_higher > 0) {
      odds_ratio <- case_higher / control_higher
    } else {
      odds_ratio <- Inf
    }
  } else {
    chi_sq <- 0
    p_value <- 1
    odds_ratio <- 1
  }
  
  # Return results
  result <- list(
    odds_ratio = odds_ratio,
    chi_squared = chi_sq,
    p_value = p_value,
    case_higher = case_higher,
    control_higher = control_higher,
    method = method,
    test = "Case-Crossover Analysis"
  )
  
  class(result) <- "casecross_test"
  return(result)
}

# Print method for casecross_test objects
print.casecross_test <- function(x, ...) {
  cat("\n")
  cat("Case-Crossover Test Results\n")
  cat("============================\n")
  cat(sprintf("Test Method: %s\n", x$method))
  cat(sprintf("Odds Ratio: %.4f\n", x$odds_ratio))
  cat(sprintf("Chi-squared statistic: %.4f\n", x$chi_squared))
  cat(sprintf("P-value: %.4f\n", x$p_value))
  cat(sprintf("Case > Control: %d\n", x$case_higher))
  cat(sprintf("Control > Case: %d\n", x$control_higher))
  
  if (x$p_value < 0.05) {
    cat("\nResult: Statistically significant at alpha = 0.05\n")
  } else {
    cat("\nResult: Not statistically significant at alpha = 0.05\n")
  }
  cat("\n")
  invisible(x)
}

# Example usage
cat("Example 1: Single case with multiple control periods\n")
cat("=====================================================\n")
# Simulate exposure data
# Case period: high exposure
case_exposure <- 8

# Control periods: lower exposures
control_exposures <- c(3, 2, 4, 3, 2)

result1 <- casecross_test(case_exposure, control_exposures)
print(result1)

cat("\n\nExample 2: Multiple cases\n")
cat("==========================\n")
# Multiple cases, each with control periods
case_exposures <- c(7, 8, 9, 6)
control_matrix <- matrix(c(2, 3, 2, 4,
                           3, 2, 3, 3,
                           2, 4, 2, 2,
                           3, 3, 4, 3), 
                        nrow = 4, byrow = TRUE)

result2 <- casecross_test(case_exposures, control_matrix)
print(result2)

cat("\n\nExample 3: No significant difference\n")
cat("=====================================\n")
# Case and control periods with similar exposures
case_exposure_3 <- 4
control_exposures_3 <- c(3, 4, 5, 4, 3)

result3 <- casecross_test(case_exposure_3, control_exposures_3)
print(result3)
