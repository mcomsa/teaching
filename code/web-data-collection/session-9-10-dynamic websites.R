# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 9: Collecting Data from Dynamic Websites
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### FORMS ==============================================================================

# setting up a browser session ----------------------------------------------------------
browser_session <- rvest::html_session("https://www.google.de/")

# parse forms ---------------------------------------------------------------------------
parsed_forms <- rvest::html_form(browser_session)
parsed_forms

# provide input and submit --------------------------------------------------------------
input <- rvest::set_values(form = parsed_forms[[1]], q = "wednesday")
html_response <- rvest::submit_form(session = browser_session, form = input)

# parse response ------------------------------------------------------------------------
parsed_response <- xml2::read_html(html_response)
parsed_response
# can fail if reponse doesn't load soon enough for rvest to collect, then selenium


#### SELENIUM ===========================================================================

# start a selenium server ---------------------------------------------------------------
selenium_server <- rsDriver(verbose = TRUE, browser = "firefox", port = 4445L, 
                            version = "3.5.3", phantomver = NULL)
class(selenium_server)
# adjust you browser, port, and version, check which settings work for you

# assign client -------------------------------------------------------------------------
remote_driver <- selenium_server$client
class(remote_driver)

# open a browser session ----------------------------------------------------------------
remote_driver$open()

# navigate to page ----------------------------------------------------------------------
remote_driver$navigate("https://twitter.com/speakerpelosi")

# identify search bar -------------------------------------------------------------------
search_bar <- remote_driver$findElement(using = "xpath", value = "//input")

# submit query and select search result -------------------------------------------------
search_bar$sendKeysToElement(list("Kamala Harris"))
search_bar$submitElement()
# or: search_bar$sendKeysToElement(list("Kamala Harris", key = "enter"))

# go back to previous page --------------------------------------------------------------
remote_driver$goBack()

# scroll down to end of page ------------------------------------------------------------
page_body <- remote_driver$findElement(using = "xpath", value = "html/body")
page_body$sendKeysToElement(list(key = "end"))

# scroll down and collect several pages of tweets ---------------------------------------
remote_driver$refresh()
page_body <- remote_driver$findElement(using = "xpath", value = "html/body")
for (i in 1:3) {
  # collect and parse the live dom
  live_dom <- remote_driver$getPageSource() %>% 
    unlist() %>% 
    read_html()
  # collect information from the current timeline
  current_timeline <- html_nodes(live_dom, xpath = "//div[contains(@aria-label, 'Timeline: Tweets')]/div/div")
  tweet_meta <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[1]") %>%
    html_text()
  tweet_id <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[1]/div/div/div/a[1]") %>%
    html_attr("href")
  tweet_text <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[2]/div[1]") %>%
    html_text()
  tweet_comments <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[2]/div[last()]/div[1]//span") %>%
    html_text()
  tweet_retweets <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[2]/div[last()]/div[2]//span") %>%
    html_text()
  tweet_likes <- html_nodes(current_timeline, xpath = "//div[@data-testid = 'tweet']/div[2]/div[2]/div[last()]/div[3]//span") %>%
    html_text()
  # process information
  author <- stringr::str_remove(tweet_meta, "@.+")
  handle <- stringr::str_extract(tweet_meta, "@.+(?=·)")
  date <- stringr::str_extract(tweet_meta, "[:digit:].+")
  id <- stringr::str_extract(tweet_id, "[:digit:].+")
  # store information
  current_timeline <- data.frame(author = author,
                                 handle = handle,
                                 date = date,
                                 id = id,
                                 post = tweet_text,
                                 comments = tweet_comments,
                                 likes = tweet_likes)
  if (i == 1) {
    timeline <- current_timeline
  } else {
    timeline <- rbind(timeline, current_timeline)
  }
  # scroll down
  # page_body$sendKeysToElement(list(key = "end")) # scrolls too far down
  for(j in 1:runif(n = 1, min = 4, max = 6)) {
    page_body$sendKeysToElement(list(key = "page_down"))
    Sys.sleep(runif(n = 1, min = 0.5, max = 1))  
  }
  Sys.sleep(runif(1, min = 3, max = 6))
  timeline <- dplyr::distinct(timeline, id, .keep_all = TRUE)
}