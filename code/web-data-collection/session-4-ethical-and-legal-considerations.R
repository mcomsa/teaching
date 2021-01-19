# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 4: Ethical and legal considerations
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### SPECIFYING THE USER-AGENT ==========================================================

# assign url ----------------------------------------------------------------------------
persons_url <- "https://www.polver.uni-konstanz.de/fachbereich/personen/personen/"
travels_url <- "https://history.state.gov/departmenthistory/travels/president/trump-donald-j"
petitions_url <- "http://lda.data.parliament.uk/epetitions.xml?_pageSize=500&_page=0"

# setting up a browser session ----------------------------------------------------------
browser_session <- html_session(persons_url)
class(browser_session)

# find user-agent -----------------------------------------------------------------------
browser_session$response$request$options$useragent

# change user_agent ---------------------------------------------------------------------
stringr::str_c("YOUR EMAIL ADDRESS", "YOUR DATA COLLECTION PURPOSE",
      R.version$platform,
      R.version$version.string,
      sep = ", ") %>%
  httr::user_agent() %>%
  httr::set_config()

# check user-agent ----------------------------------------------------------------------
browser_session <- html_session(url = persons_url)
browser_session$response$request$options$useragent

# reset user-agent ----------------------------------------------------------------------
# httr::reset_config()


#### ASKING FOR PERMISSION ==============================================================

# to quickly check robots.txt -----------------------------------------------------------
robotstxt::paths_allowed(paths = persons_url)
# tries to guess the domain

# detailed check of robots.txt ----------------------------------------------------------
persons_url_parsed <- xml2::url_parse(persons_url)
persons_robotstxt <- robotstxt::robotstxt(persons_url_parsed$server)
persons_robotstxt$permissions
persons_robotstxt$check(persons_url_parsed$path)
persons_robotstxt$crawl_delay

travels_url_parsed <- url_parse(travels_url)
travels_robotstxt <- robotstxt::robotstxt(travels_url_parsed$server)
travels_robotstxt$permissions
travels_robotstxt$check(persons_url_parsed$path)
travels_robotstxt$crawl_delay

petitions_url_parsed <- url_parse(petitions_url)
petitions_robotstxt <- robotstxt::robotstxt(petitions_url_parsed$server)
petitions_robotstxt$permissions
petitions_robotstxt$check(petitions_url_parsed$path)
petitions_robotstxt$crawl_delay


#### SUSPENDING CALLS TO A WEBSITE ======================================================

# assign urls for all petitions ---------------------------------------------------------
petitions_urls <- stringr::str_c("http://lda.data.parliament.uk/epetitions.xml?_pageSize=500&_page=", 0:31)
petitions_urls

# remove existing file in xmls folder ---------------------------------------------------
path <- file.path("xmls","petitions")
file.remove(str_c(path, "/", list.files(path)))

# download xml files ---------------------------------------------------------------------
filenames <- str_c("e-petitions", "-", 0:31, ".xml")

for (i in 1:length(filenames)) {
  cat(filenames[i], "\n")
  xml2::download_xml(url = petitions_urls[i],
                     file = file.path(path, filenames[i]))
  Sys.sleep(1)
}
