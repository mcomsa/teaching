# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 5 AND 6: Collecting data from static websites: XPath
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### SPECIFY USER-AGENT =================================================================

# adjust user_agent ---------------------------------------------------------------------
str_c("YOUR EMAIL ADDRESS", 
      "YOUR DATA COLLECTION PURPOSE",
      R.version$platform,
      R.version$version.string,
      sep = ", ") %>%
  httr::user_agent() %>%
  httr::set_config()


#### DOWNLOAD AND PARSE HTML/XML FILES ==================================================

# assign and parse urls ---------------------------------------------------------------------------
persons_url <- "https://www.polver.uni-konstanz.de/fachbereich/personen/personen/"
persons_url_parsed <- xml2::url_parse(persons_url)

travels_url <- "https://history.state.gov/departmenthistory/travels/president/trump-donald-j"
travels_url_parsed <- xml2::url_parse(travels_url)

petitions_url <- "http://lda.data.parliament.uk/epetitions.xml?_pageSize=500&_page=0"
petitions_url_parsed <- xml2::url_parse(petitions_url)

# ask for permission --------------------------------------------------------------------
persons_robotstxt <- persons_url_parsed$server %>%  
  robotstxt()
persons_url_parsed$path %>%
  persons_robotstxt$check()
persons_robotstxt$crawl_delay

travels_robotstxt <- travels_url_parsed$server %>%  
  robotstxt()
travels_url_parsed$path %>%
  travels_robotstxt$check()
travels_robotstxt$crawl_delay

petitions_robotstxt <- petitions_url_parsed$server %>%  
  robotstxt()
petitions_url_parsed$path %>%
  petitions_robotstxt$check()
petitions_robotstxt$crawl_delay

# create folders to store htmls ---------------------------------------------------------
persons_path <- file.path("htmls","persons")
if (!dir.exists(persons_path)) {
  persons_path %>%
    dir.create(recursive = TRUE)
}

travels_path <- file.path("htmls","travels")
if (!dir.exists(travels_path)) {
  travels_path %>%
    dir.create(recursive = TRUE)
}

petitions_path <- file.path("xmls","petitions")
if (!dir.exists(petitions_path)) {
  petitions_path %>%
    dir.create(recursive = TRUE)
}

# download the html files ----------------------------------------------------------------
persons_filename <- persons_url %>%
  basename() %>%
  stringr::str_c(".html")
if (!file.exists(file.path(persons_path, persons_filename))) {
  xml2::download_html(url = persons_url,
                      file = file.path(persons_path, persons_filename))
}

travels_filename <- travels_url %>%
  basename() %>%
  stringr::str_c(".html")
if (!file.exists(file.path(travels_path, travels_filename))) {
  xml2::download_html(url = travels_url,
                      file = file.path(travels_path, travels_filename))
}

petitions_filename <- "e-petitions-0.xml"
if (!file.exists(file.path(petitions_path, petitions_filename))) {
  xml2::download_xml(url = petitions_url,
                      file = file.path(petitions_path, petitions_filename))
}

# parse html files ----------------------------------------------------------------------
persons_parsed <- persons_path %>%
  file.path(persons_filename) %>%
  xml2::read_html()
persons_parsed

travels_parsed <- travels_path %>%
  file.path(travels_filename) %>%
  xml2::read_html(encoding = "UTF-8") # specify encoding explicitly
travels_parsed

petitions_parsed <- petitions_path %>%
  file.path(petitions_filename) %>%
  xml2::read_xml()
petitions_parsed


#### EXTRACT INFORMATION USING XPATH ====================================================

# extract names from persons_parsed -----------------------------------------------------
browseURL(persons_url)

# absolute path to node
name_node <- persons_parsed %>%
  rvest::html_node(xpath = "/html/body/div/div/section/div/div/div/section/div/div/h2")

# content of node
name_node %>%
  rvest::html_text() # just one name!

# all names
persons_parsed %>%
  rvest::html_nodes(xpath = "/html/body/div/div/section/div/div/div/section/div/div/h2") %>%
  rvest::html_text()

# relative path
persons_parsed %>%
  rvest::html_nodes(xpath = "//h2") %>%
  rvest::html_text() # gives more than we want!

persons_parsed %>%
  rvest::html_nodes(xpath = "//section/div/div/h2") %>%
  rvest::html_text()

# using the attribute predicate
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[@class = 'name-container toggle']/h2") %>%
  rvest::html_text()

# using the position predicate
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[2]/h2") %>%
  rvest::html_text()

# using the position predicate
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[position() = 2]/h2") %>%
  rvest::html_text()

# using text predicates to get only professors
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[@class = 'name-container toggle']/h2[contains(text(), 'Prof.')]") %>%
  rvest::html_text()

# using text predicates and operators to get only professors, exluding 'Jun.-Profs'
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[@class = 'name-container toggle']/h2[contains(text(), 'Prof.') and not(contains(text(), 'Jun.'))]") %>%
  rvest::html_text()

# using text predicates and operators to get only junior professors
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[@class = 'name-container toggle']/h2[contains(text(), 'Jun.')]") %>%
  rvest::html_text()

# extract working groups from persons_parsed --------------------------------------------

# relative path to all working groups
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[2]/p") %>%
  rvest::html_text()

# using node relations to get working groups of professors
persons_parsed %>%
  rvest::html_nodes(xpath = "//div[2]/h2[contains(text(), 'Prof.')]/following-sibling::p") %>%
  rvest::html_text()
# if more than one following sibling, add position, i.e., p[1]

# extract table of travels from travels_parsed ------------------------------------------
browseURL(travels_url)

# absolute path to node
travels_node <- travels_parsed %>%
  rvest::html_node(xpath = "/html/body/div/section/div/main/div/div/div/table")

# content of node
travels_node %>%
  rvest::html_table() %>%
  View()

# relative path
travels_node <- travels_parsed %>%
  rvest::html_node(xpath = "//table") %>%
  rvest::html_table() %>%
  View()

# extract petitions from petitions_parsed -----------------------------------------------
browseURL(petitions_url)

# show nodes
xml2::xml_contents(petitions_parsed)

# get relevant node
petitions_node <- xml2::xml_contents(petitions_parsed)[5] # content is in node 5 (items)
petitions_node

# get relevant node set
petitions_nodeset <- petitions_node %>%
  xml2::xml_find_first(xpath = "//items/item") %>%
  xml2::xml_children()
petitions_nodeset

# construct XPath queries
petitions_xpath <- petitions_nodeset %>%
  xml2::xml_name() %>%
  stringr::str_c("//items/item/", .)
petitions_xpath
petitions_xpath[5] <- petitions_xpath[5] %>%
  stringr::str_c("/item")
petitions_xpath

# extract information into data frame using a for loop 1
petitions_data <- matrix(ncol = 6, nrow = 500) %>%
  data.frame() %>%
  set_names(xml2::xml_name(petitions_nodeset))
for (i in 1:length(petitions_nodeset)) {
  petitions_data[,i] <- petitions_node %>%
    xml_find_all(xpath = petitions_xpath[i]) %>%
    xml_text()
}

# extract information into data frame using a for loop 2
for (i in 1:length(petitions_nodeset)) {
  petitions_subdata <- petitions_node %>%
    xml_find_all(xpath = petitions_xpath[i]) %>%
    xml_text()
  if (i == 1) {
    petitions_list <- list(petitions_subdata)
  } else {
    petitions_list <- c(petitions_list, list(petitions_subdata))
  }
}
petitions_data <- petitions_list %>%
  bind_cols() %>%
  set_names(xml2::xml_name(petitions_nodeset))
petitions_data %>% View()

# extract information into a dataframe using lapply
petitions_data <- lapply(X = petitions_xpath, 
                         FUN = xml_find_all, 
                         x = petitions_node) %>%
  sapply(X = ., FUN = xml_text) %>%
  as.data.frame() %>%
  set_names(xml2::xml_name(petitions_nodeset))
petitions_data %>% View()

# extract information into data frame using purrr 1
petitions_data <- petitions_xpath %>%
  purrr::map(xml2::xml_find_all, x = petitions_node) %>%
  purrr::map_dfc(xml2::xml_text) %>%
  set_names(xml2::xml_name(petitions_nodeset))
petitions_data %>% View()

# extract information into data frame using purrr 2
petitions_xpath %>%
  purrr::map_dfc(~{.x %>%
    xml2::xml_find_all(x = petitions_node) %>%
      xml2::xml_text()
  }) %>%
  set_names(xml2::xml_name(petitions_nodeset))

# alternatively - flat_xml package
flat_xml <- petitions_path %>%
  file.path(petitions_filename) %>%
  flatxml::fxml_importXMLFlat() # View to inspect element IDs
flat_xml %>%
  flatxml::fxml_toDataFrame(siblings.of = 11) %>% # use element ID of siblings
  View() # doesn't catch the sponsors 

# alternatively - XML package
petitions_data <- petitions_path %>%
  file.path(petitions_filename) %>%
  XML::xmlParse() %>%
  XML::getNodeSet(path = "//items/item") %>%
  XML::xmlToDataFrame()
petitions_data %>% View()


#### SCALING UP =========================================================================

# building a download/collector function ------------------------------------------------
collector <- function(url, path, filename, progressbar = TRUE, crawl_delay = 1) {
  # create filename if missing
  if (missing(filename)) {
    is_xml <- url %>%
      stringr::str_detect("xml")
    if (is_xml) {
      filename <- url %>%
        basename() %>%
        stringr::str_c(".xml")
    } else {
      filename <- url %>%
        basename() %>%
        stringr::str_c(".html")
    }
  }
  # construct the file path and create folder if missing
  filepath <- path %>%
    file.path(filename)
  if (!dir.exists(path)) {
    path %>%
      dir.create(recursive = TRUE)
  }
  # download file if missing
  if (!file.exists(filepath)) {
    if (tools::file_ext(filepath) == "html") {
      try(download_html(url = url, file = filepath),
          silent = TRUE)
    } else if (tools::file_ext(filepath) == "xml") { 
      try(download_xml(url = url, file = filepath),
          silent = TRUE)
    } else {
      stop("file is neither HTML nor XML")
    }
  }
  # suspend next call
  Sys.sleep(crawl_delay)
  # report progress
  if (progressbar) {
      pb$tick()
  }
}

# set parameters for downloading presidents' travels index page -------------------------
travels_index_url <- c("https://history.state.gov/departmenthistory/travels/president")
path <- "./htmls/travels"
filename <- "presidents.html"
pb <- progress::progress_bar$new(total = length(travels_index_url),
                                 show_after = 0,
                                 clear = FALSE)

# download index html -------------------------------------------------------------------
travels_index_url %>%
  purrr::walk(collector, 
              path = path,
              filename = filename)

# use XPath to extract links to all presidents' travels ---------------------------------
browseURL(travels_index_url)
travels_urls <- path %>%
  file.path(filename) %>%
  xml2::read_html() %>%
  rvest::html_nodes(xpath = "//h3[text() = 'By President']/following-sibling::ul/li/a") %>%
  # rvest::html_nodes(xpath = "//div[@class = 'col-md-8']/ul/li/a") %>% # easier
  rvest::html_attr("href") %>%
  stringr::str_c("https://history.state.gov/", .)
travels_urls

# download all urls ---------------------------------------------------------------------
path <- "./htmls/travels/all_travels"
pb <- progress::progress_bar$new(total = length(travels_urls),
                                 show_after = 0,
                                 clear = FALSE)
travels_urls %>%
  purrr::walk(collector, 
              path = path,
              crawl_delay = travels_robotstxt$crawl_delay$value)

# getting a data frame of all presidents' travels ---------------------------------------
all_travels <- path %>%
  list.files() %>%
  file.path(path, .) %>%
  purrr::map(xml2::read_html, encoding = "UTF-8") %>%
  purrr::map(rvest::html_node, xpath = "//table") %>%
  purrr::map_dfr(rvest::html_table)
all_travels %>% View()  # the presidents themselves are missing
  
# getting a data frame of all presidents' travels including the presidents --------------
all_names <- path %>%
  list.files() %>%
  file.path(path, .) %>%
  purrr::map(xml2::read_html, encoding = "UTF-8") %>%
  purrr::map(rvest::html_node, xpath = "//h1") %>%
  purrr::map(rvest::html_text) %>%
  stringr::str_trim() # remove redundant whitespace

all_travels <- path %>%
  list.files() %>%
  file.path(path, .) %>%
  purrr::map(xml2::read_html, encoding = "UTF-8") %>%
  purrr::map(rvest::html_node, xpath = "//table") %>%
  purrr::map(rvest::html_table) %>%
  purrr::imap_dfr(~{.x %>% # add the respective president
      dplyr::mutate(President = all_names[.y])
  })

all_travels %>% View()