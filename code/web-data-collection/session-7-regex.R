# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 7: Regular expressions and data cleaning
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### EXTRACT INFORMATION FROM DOWNLOADED HTMLS ==========================================

# specify file path and filename --------------------------------------------------------
persons_path <- file.path("htmls","persons")
persons_filename <- list.files(persons_path)

travels_path <- file.path("htmls","travels", "all_travels")
travels_filename <- list.files(travels_path)

petitions_path <- file.path("xmls","petitions")
petitions_filename <- list.files(petitions_path)

# parse files ---------------------------------------------------------------------------
persons_parsed <- persons_path %>%
  file.path(persons_filename) %>%
  xml2::read_html()

travels_parsed <- travels_path %>%
  file.path(travels_filename) %>%
  purrr::map(xml2::read_html)

petitions_parsed <- petitions_path %>%
  file.path(petitions_filename) %>%
  gtools::mixedsort(decreasing = TRUE) %>%
  purrr::map(XML::xmlParse)

# extract desired information using XPath -----------------------------------------------
persons_names <- persons_parsed %>%
  rvest::html_nodes(xpath = "//div[2]/h2") %>%
  rvest::html_text()

president_names <- travels_path %>%
  file.path(travels_filename) %>%
  purrr::map(xml2::read_html, encoding = "UTF-8") %>%
  purrr::map(rvest::html_node, xpath = "//h1") %>%
  purrr::map(rvest::html_text) %>%
  stringr::str_trim() # remove redundant whitespace
travels_data <- travels_path %>%
  file.path(travels_filename) %>%
  purrr::map(xml2::read_html, encoding = "UTF-8") %>%
  purrr::map(rvest::html_node, xpath = "//table") %>%
  purrr::map(rvest::html_table) %>%
  purrr::imap_dfr(~{.x %>% # add the respective president
      mutate(President = president_names[.y])
  })

petitions_data <- petitions_parsed %>%
  purrr::map(XML::getNodeSet, path = "//items/item") %>%
  purrr::map_dfr(XML::xmlToDataFrame)


#### CLEANING DATA WITH REGULAR EXPRESSIONS =============================================

# clean person_names and store in data frame --------------------------------------------
persons_names %>% head
persons_names %>% stringr::str_remove_all("^\\s+(?=[^:space:])|(?<=[^:space:])\\s+$|\n") # remove trailing and leading whitespace
persons_names <- persons_names %>% 
  stringr::str_trim() # or much simpler
persons_data <- data.frame(name = persons_names)
persons_data %>% View()

# create indicators for profs, assistant profs, and only doctoral degrees ---------------
persons_data$prof <- persons_data$name %>%
  stringr::str_detect("^Prof\\.")
persons_data$assist_prof <- persons_data$name %>%
  stringr::str_detect("^Jun\\.")
persons_data$doc_only <- persons_data$name %>%
  stringr::str_detect("^(PD\\s)?Dr\\.")
persons_data$others <- ifelse(persons_data$prof == FALSE &
                              persons_data$assist_prof == FALSE &
                              persons_data$doc_only == FALSE, TRUE, FALSE)

# extract first name --------------------------------------------------------------------
persons_data$first_names <- persons_data$name %>%
  stringr::str_remove_all("Jun\\.-|Prof\\.|PD\\s|Dr\\.") %>%
  stringr::str_trim() %>%
  stringr::str_extract("^[:alpha:]+(-[:alpha:]+)?\\s") %>%
  stringr::str_trim() %>%
  tolower()

# predict gender based on first names ---------------------------------------------------
persons_gender <- persons_data$first_names %>%
  gender::gender(method = "genderize")
persons_gender %>% View()
persons_data$gender <- ifelse(persons_gender$proportion_female > 0.9, "female",
                        ifelse(persons_gender$proportion_male > 0.9, "male",
                               NA))

persons_data %>%
  dplyr::filter(!is.na(gender))

missing_gender <- which(is.na(persons_data$gender))
persons_data$name[missing_gender]
persons_data$gender <- persons_data$gender %>%
  magrittr::inset(missing_gender, 
        c("female", "female", "female", "female", "male", 
          "male", "female", "male", "female"))



# report results ------------------------------------------------------------------------

# reshape data
persons_data$position <- ifelse(persons_data$prof == TRUE, "prof",
                          ifelse(persons_data$assist_prof == TRUE, "assist_prof",
                           ifelse(persons_data$doc_only == TRUE, "doc_only",
                           ifelse(persons_data$others == TRUE, "others", 
                                  NA)))) %>%
  factor(levels = c("prof", "assist_prof", "doc_only", "others"))
persons_data$gender <- persons_data$gender %>%
  factor(levels = c("female", "male"))

# cross tabs
persons_data$gender %>% 
  table() %>% 
  prop.table() %>% 
  magrittr::multiply_by(100) %>% 
  round(digits = 1)
persons_data$position %>% 
  table(persons_data$gender) %>% 
  prop.table() %>% 
  magrittr::multiply_by(100) %>% 
  round(digits = 1)

# plot data
ggplot2::ggplot(data = persons_data) +
  ggplot2::geom_bar(aes(x = position, fill = gender)) +
  ggplot2::labs(y = "")

ggplot2::ggplot(data = persons_data) +
  ggplot2::geom_bar(aes(x = position, y = (..count..)/sum(..count..), fill = gender)) +
  ggplot2::labs(y = "")

# clean travel locations ----------------------------------------------------------------

# replace empty location (Vatican City) with country
travels_data$Locale <- ifelse(stringi::stri_isempty(travels_data$Locale),
                              travels_data$Country, travels_data$Locale)

# keep only first location
travels_data$Locale <- travels_data$Locale %>%
  stringr::str_remove("\\,.+")

# correct country information (in brackets)
#travels_data$Country <- ifelse(stringr::str_detect(travels_data$Locale, "\\("),
#                               stringr::str_extract(travels_data$Locale, "(?<=\\().+(?=\\))"),
#                               travels_data$Country) # lookbehind and lookahead together

# remove content in brackets from locations
travels_data$Locale <- travels_data$Locale %>%
  stringr::str_remove("\\(.+?\\)") %>%
  stringr::str_squish()

# format countries correctly
travels_data$Country <- travels_data$Country %>%
  stringr::str_extract(",.+") %>%
  stringr::str_replace_na("") %>%
  stringr::str_c(travels_data$Country, sep = " ") %>%
  stringr::str_remove_all("^,\\s|,\\s.+") %>%
  stringr::str_trim()

# create address
travels_data$address <- stringr::str_c(travels_data$Locale, ", ", travels_data$Country)

# geocode addresses
travels_data <- travels_data$address %>%
  tidygeocoder::geo(method = "osm") %>%
  dplyr::select(lat, long) %>%
  dplyr::bind_cols(travels_data)
travels_data <- travels_data %>%
  dplyr::filter(!is.na(lat))


# clean and parse travel dates ----------------------------------------------------------
travels_data$Date %>% head()
lubridate::as_date(travels_data$Date[1:2])
lubridate::mdy(travels_data$Date[1:2])
travels_data$parsed_date <- travels_data$Date %>%
  stringr::str_remove("\u2013.+(?=,)") %>% # unicode for en dash, not -, lookahead
  stringr::str_remove("(?<=[:digit:]{4}),.+") %>% # lookbehind
  stringr::str_squish() %>%
  lubridate::mdy()

# report results ------------------------------------------------------------------------

# format data for plotting
travels_data$President <- travels_data$President %>%
  factor()
travels_data$year_month <- travels_data$parsed_date %>%
  cut(breaks = "months") %>%
  as_date()

# plot all travels on a world map - history book style!
world_map <- ne_countries(scale = "medium", returnclass = "sf")
ggplot2::ggplot() +
  ggplot2::geom_sf(data = world_map, fill = "antiquewhite") +
  ggplot2::geom_point(aes(x = travels_data$long, y = travels_data$lat), 
             color = "firebrick", alpha = 0.5) +
  ggplot2::labs(x = "Longitude", y = "Latitude") +
  ggplot2::ggtitle("Travels of US Presidents") +
  ggplot2::coord_sf(expand = FALSE) +
  ggplot2::theme(panel.grid.major = element_blank(),
        panel.background = element_rect(fill = "lightgray"))

# plot all travels on a world map, by presidents
ggplot2::ggplot() +
  ggplot2::geom_sf(data = world_map, fill = "antiquewhite") +
  ggplot2::geom_point(data = travels_data, aes(x = long, y = lat), 
                      color = "firebrick", alpha = 0.5) +
  ggplot2::facet_wrap(~President) +
  ggplot2::labs(x = "Longitude", y = "Latitude") +
  ggplot2::ggtitle("Travels of US Presidents") +
  ggplot2::coord_sf(expand = FALSE) +
  ggplot2::theme(panel.grid.major = element_blank(),
                 panel.background = element_rect(fill = "lightgray"))

# plot travels over time
travels_data_monthly <- travels_data %>%
  dplyr::group_by(year_month) %>%
  dplyr::summarize(count = n())
ggplot2::ggplot(data = travels_data_monthly) +
  ggplot2::geom_segment(aes(y = count, x = year_month, xend = year_month, yend = 0)) +
  ggplot2::theme_bw()

# parse dates in petitions data ---------------------------------------------------------
petitions_data$date <- petitions_data$created %>%
  lubridate::as_date()

# use regex to extract information about EU and Brexit related petitions ----------------
petitions_data$EU <- petitions_data$label %>%
  stringr::str_detect(" EU | European Union ")
petitions_data$Brexit <- petitions_data$label %>%
  tolower() %>%
  stringr::str_detect(" brexit ") # this approach likely misses plenty of matches
petitions_data$EU <- ifelse(petitions_data$Brexit == TRUE,
                            TRUE, petitions_data$EU) # brexit is EU related

# report results ------------------------------------------------------------------------

# format data for plotting 
petitions_data$year_month <- petitions_data$date %>%
  cut(breaks = "months") %>%
  lubridate::as_date()
petitions_data_monthly <- petitions_data %>%
  tidyr::pivot_longer(cols = c(8,9), names_to = "issue") %>%
  dplyr::filter(value == TRUE) %>%
  dplyr::group_by(year_month, issue) %>%
  dplyr::summarize(count = n())
  
# plot data 
ggplot2::ggplot(data = petitions_data_monthly) +
  ggplot2::geom_line(aes(y = count, x = year_month, linetype = issue)) +
  ggplot2::theme_bw()