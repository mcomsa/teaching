# Teaching Materials

This repository includes scripts for courses I taught.

**[Multilevel Modeling](#multilevel-modeling)**<br>
**[Web Data Collection with R](#web-data-collection-with-r)**<br>

## Multilevel Modeling (Frequentist and Bayesian)

This course was taught together with Peter Selb in summer semester 2018 and with Susumu Shikano in summer semester 2019 at the University of Konstanz. The latest scripts are:

* [R Primer](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/r-primer.html): This script includes a very basic introduction to R. It covers how to obtain, install, and set up R and RStudio, learning the building blocks of the R language, and the basics of working with packages and data.
* [Frequentist Multilevel Modeling in R I](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/frequentist-i.html): Fitting, evaluating, and interpreting frequentist linear multilevel models are covered in this script. It introduces lme4 and illustrates by gradually building up from varying-intercept models without predictors to varying-intercept and -slope models with individual- and group-level predictors.
* [Frequentist Multilevel Modeling in R II](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/frequentist-ii.html): This script is structured as Frequentist Multilevel Modeling in R I but focuses on generalized linear models.
* [Bayesian Multilevel Modeling in R](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/bayesian.html): Stan is introduced for Bayesian multilevel modeling in this script. It shows how to set up, fit, evaluate, and interpret linear and generalized linear multilevel models.
* [Postestimation for Multilevel Modeling in R](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/postestimation.html): In this script the focus is on quantifying uncertainty of estimates via statistical simultation for frequentist and via the posterior for bayesian multilevel models. It further shows how to generate population-averaged predictions (aka average marginal effects, observed case approach, average predictive comparisons, or average partial effects) for both frequentist and bayesian multilevel models using a custom R function (available [here](https://github.com/saschagobel/teaching/blob/master/code/multilevel-modeling/mlAMEs.R)).
* [Visually Communicating Results from Multilevel Modeling in R](http://htmlpreview.github.com/?https://github.com/saschagobel/teaching/blob/master/slides/multilevel-modeling/visualization.html): This last script provides several examples to show how to graphically display estimated parameters and population-averaged predictions from multilevel models via ggplot2.

Slides can be downloaded [here](https://github.com/saschagobel/teaching/tree/master/slides/multilevel-modeling).

## Web Data Collection with R

This course was taught in winter semester 2020/21 at the University of Konstanz.

The course syllabus and slides can be downloaded [here](https://github.com/saschagobel/teaching/tree/master/slides/web-data-collection), R code is available [here](https://github.com/saschagobel/teaching/tree/master/code/web-data-collection).

### Course Description
Finding and collecting data is a central yet often challenging and time consuming part of the research process. An increasingly popular source of information for social scientists is offered by the World Wide Web. Every day, governments, companies, and individual persons share and create large quantities of information on the internet, such as administrative records, search engine queries, website traffic, interactions on social networks, etc. The scale at which data is available on the web precludes manual data collection. Fortunately, the ways in which data are stored online often allow for automating the collection process. In this course students will learn how to identify and efficiently collect information from the web. We will cover basic knowledge about web architectures, legal and ethical concerns, the tools required to extract data from static and dynamic web pages, how to tap APIs, and how to process and explore the collected data. Most of the sessions are hands-on using R.


## Author information
**Sascha Göbel** <br />
Graduate School of Decision Sciences <br />
University of Konstanz <br />
Box 85 <br />
78457 Konstanz, Germany <br />
Email: sascha.goebel [at] uni-konstanz.de