Dataset example - function for wide-to-long format variables
================
Miruna Barbu
28/03/2022

The accompanying .r script (“wide\_to\_long\_format”) uses a function
created by myself to turn multiple variables from wide to long format.
This is useful in analyses that use repeated measures, such as linear
mixed-effects models.

The script:

1.  Loads in a dummy dataset. In this case, I created a dataset
    containing measures for three white matter tracts (anterior,
    posterior, and superior thalamic radiations), for the left and right
    hemisphere. This is a measure I regularly work with in my research,
    although the script can be applied to any variable needing to be
    transformed from wide to long format.

\*Although the dummy dataset contains 10 variables only, the script
works with large-scale datasets (I have used this with &gt;30,000
participants and up to 64 brain regions).

2.  Loads in a covariate file (this can be excluded from the function by
    commenting out lines …). This saves time from including covariates
    at later stages of the analysis process.

3.  Carries out a number of steps to prepare the data for input into the
    function. The function takes 6 arguments (or 5 in case you want to
    exclude covariates).

The script for creating dummy data is below:

    ## Print summaries of both datasets (for visualisation purposes)

    ## Dummy dataset summary:

    ##        ID        lh.antthalrad    rh.antthalrad    lh.postthalrad  
    ##  Min.   : 1.00   Min.   :0.2170   Min.   :0.2350   Min.   :0.2340  
    ##  1st Qu.: 3.25   1st Qu.:0.2727   1st Qu.:0.3387   1st Qu.:0.2785  
    ##  Median : 5.50   Median :0.3165   Median :0.3880   Median :0.3150  
    ##  Mean   : 5.50   Mean   :0.3312   Mean   :0.3754   Mean   :0.3081  
    ##  3rd Qu.: 7.75   3rd Qu.:0.3870   3rd Qu.:0.4288   3rd Qu.:0.3410  
    ##  Max.   :10.00   Max.   :0.4630   Max.   :0.4770   Max.   :0.3710  
    ##  rh.postthalrad   lh.supthalrad    rh.supthalrad   
    ##  Min.   :0.2080   Min.   :0.2000   Min.   :0.2050  
    ##  1st Qu.:0.3175   1st Qu.:0.2807   1st Qu.:0.2615  
    ##  Median :0.4530   Median :0.3545   Median :0.3215  
    ##  Mean   :0.3978   Mean   :0.3410   Mean   :0.3219  
    ##  3rd Qu.:0.4698   3rd Qu.:0.3990   3rd Qu.:0.3757  
    ##  Max.   :0.4830   Max.   :0.4540   Max.   :0.4380

    ## Dummy covariate summary:

    ##        ID        sex        age       
    ##  Min.   : 1.00   0:6   Min.   :26.00  
    ##  1st Qu.: 3.25   1:4   1st Qu.:29.25  
    ##  Median : 5.50         Median :31.50  
    ##  Mean   : 5.50         Mean   :32.30  
    ##  3rd Qu.: 7.75         3rd Qu.:34.75  
    ##  Max.   :10.00         Max.   :40.00
