# hello-world
This is a store for practice in quickstart guide
This is my first time to visit Github, because I want to learn something about programming and newly developed statistical methods from Github. So let's start it!

## Case-Crossover Test in R

This repository now includes an implementation of the case-crossover statistical test in R (`casecross_test.R`).

### What is Case-Crossover Design?

Case-crossover design is a within-person comparison method used in epidemiology to study the effect of transient exposures on the risk of acute events. It is particularly useful for studying rare events where each case serves as their own control.

### Usage

Run the script with R:
```bash
Rscript casecross_test.R
```

Or source it in your R session:
```R
source("casecross_test.R")

# Single case with multiple control periods
case_exposure <- 8
control_exposures <- c(3, 2, 4, 3, 2)
result <- casecross_test(case_exposure, control_exposures)
print(result)
```

### Features

- Performs case-crossover analysis using McNemar's test approach
- Calculates odds ratios and statistical significance
- Supports single or multiple cases
- Includes example demonstrations
- Formatted output with interpretation
