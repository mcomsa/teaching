# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 3: Basic Web Technologies
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### COMPONENTS OF A URL ================================================================

# assign url ----------------------------------------------------------------------------
persons_url <- "https://www.polver.uni-konstanz.de/fachbereich/personen/personen/"
travels_url <- "https://history.state.gov/departmenthistory/travels/president/trump-donald-j"

# parse url -----------------------------------------------------------------------------
xml2::url_parse(persons_url)
xml2::url_parse(travels_url)

# open url in browser -------------------------------------------------------------------
browseURL(persons_url)
browseURL(travels_url)

# name of current html ------------------------------------------------------------------
filename <- stringr::str_c(basename(persons_url), ".html")


#### DOWNLOADING AND PARSING AN HTML FILE ===============================================

# create a folder to store htmls --------------------------------------------------------
path <- file.path("htmls","persons")
if (!dir.exists("htmls")) {
   path %>%
    dir.create(recursive = TRUE)
}

# download the html file ----------------------------------------------------------------
xml2::download_html(url = persons_url,
                    file = file.path(path, filename))

# parse the html file and traverse the tree ---------------------------------------------
persons_parsed <- xml2::read_html(file.path(path, filename))
persons_parsed
xml2::xml_find_all(persons_parsed, "//div")
xml2::xml_find_all(persons_parsed, "//div/div")
xml2::xml_find_all(persons_parsed, "//div/div/section")
html_structure(xml2::xml_find_all(persons_parsed, "//div/div/section")[2])
xml2::xml_find_all(persons_parsed, "//div/div/section/div/div/h2")


#### DOWNLOADING AND PARSING AN XML FILE ================================================

# assign url ----------------------------------------------------------------------------
petitions_url <- "http://lda.data.parliament.uk/epetitions.xml?_pageSize=500&_page=0"

# open url in browser -------------------------------------------------------------------
browseURL(petitions_url)

# create a folder to store htmls --------------------------------------------------------
path <- file.path("xmls","petitions")
if (!dir.exists("xmls")) {
  path %>%
    dir.create(recursive = TRUE)
}

# name of current html ------------------------------------------------------------------
filename <- "e-petitions.xml"

# download the xml file -----------------------------------------------------------------
xml2::download_xml(url = petitions_url,
                   file = file.path(path, filename))

# parse the html file and traverse the tree ---------------------------------------------
petitions_parsed <- xml2::read_xml(file.path(path, filename))
petitions_parsed
