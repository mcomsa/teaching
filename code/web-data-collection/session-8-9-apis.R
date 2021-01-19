# ---------------------------------------------------------------------------------------
# WEB DATA COLLECTION WITH R
# Sascha Goebel
# SESSION 8: Collecting Data from APIs
# Winter Semester 2020/21
# ---------------------------------------------------------------------------------------


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("web-data-collection-r")

# install and load packages -------------------------------------------------------------
source("code/packages.R")


#### REGISTER WITH THE TWITTER API ======================================================

# (1) apply for a Twitter developer account 
# (2) log in with the Twitter account that is paired with the developer account
# (3) navigate to the Twitter developer dashboard
browseURL("https://developer.twitter.com/en/portal/dashboard")

# two ways to obtain Twitter credentials for API access

# 1: navigate to "Projects & Apps" and select your standalone or project apps, next 
#    select keys and tokens, here you can view your API key and secret (consumer key and
#    secret) and generate an Access token and secret. These are for access via OAuth 1.0.
#    The bearer token can be used for access via OAuth 2.0.

# For access via OAuth 1.0 assign your SECRET! keys and secrets to separate objects
consumer_key <- "xxxxxxxxxxxxxxxxxx" # replace with your API key
consumer_secret <- "xxxxxxxxxxxxxxxxxx" # replace with your API secret
access_token <- "xxxxxxxxxxxxxxxxxx" # replace with your access token
access_secret <- "xxxxxxxxxxxxxxxxxx" # replace with your access secret

# create OAuth application
application <- httr::oauth_app(appname = "uni-kn-teaching-app",
                               key = consumer_key, 
                               secret = consumer_secret)

# sign OAuth request using access token and secret
signature <- httr::sign_oauth1.0(application, 
                                 token = access_token,
                                 token_secret = access_secret)


# For access via OAuth 2.0 just assign your SECRET! bearer token to an object
bearer_token <- str_c("Bearer", 
                      "xxxxxxxxxxxxxxxxxx", # replace with your bearer token
                      sep = " ")

# 2: If you have enabled three-legged OAuth in your app's authentication settings you can
#    use this approach. This allows for other Twitter accounts to authorize your app,
#    so that you can use their authentication details to collect data or post on their 
#    behalf. Possible but not necessary to do this with your own acount, see approach 1.
#    This requires a callback URL (localhost is not permitted).

# download SSL certificates/curl certificate
download.file(url = "http://curl.haxx.se/ca/cacert.pem", destfile = "cacert.pem")
# set SSL as global option
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", 
                                                 package = "RCurl")))

# create class OAuth object to manage OAuth authentification ----------------------------
OAuth <- ROAuth::OAuthFactory$new(
  consumerKey = consumer_key,
  consumerSecret = consumer_secret,
  requestURL = "https://api.twitter.com/oauth/request_token",
  accessURL = "https://api.twitter.com/oauth/access_token",
  authURL = "https://api.twitter.com/oauth/authorize"
)

# To ask for an access token and secret you need to be logged in with your account or
# with another account that you wish to authorize your app.
OAuth$handshake(cainfo = "cacert.pem")
# The handshake opens a browser window, accept authorization and copy the pin into the 
# console and execute. Then retrieve the access token and secret.
OAuth$oauthKey
OAuth$oauthSecret


#### ACCESSING THE TWITTER API ==========================================================

# currently two different versions of the API available, both supporting OAuth 1.0 and 2.0

# using API version 1 and GET -----------------------------------------------------------
response_1 <- httr::GET(url = "https://api.twitter.com/1.1/users/lookup.json?",
                        query = list(screen_name = "GOPChairwoman"),
                        config = signature)
response_1

# using API version 2, the bearer token and GET -----------------------------------------
response_2 <- httr::GET(url = str_c("https://api.twitter.com/2/users/by/username/", 
                                    "GOPChairwoman"),
                        config = httr::add_headers(Authorization = bearer_token))
response_2

# inspecting the response ---------------------------------------------------------------
# headers
response_1$headers
response_1$headers$`x-rate-limit-remaining`
response_2$headers$`x-rate-limit-remaining`
response_1$headers$`x-rate-limit-reset` %>%
  as.integer() %>%
  as.POSIXct(origin = "1970-01-01", tz= "CET")
response_2$headers$`x-rate-limit-reset` %>%
  as.integer() %>%
  as.POSIXct(origin = "1970-01-01", tz="CET")

# content
parsed_response_1 <- httr::content(x = response_1)
str(parsed_response_1)
parsed_response_2 <- httr::content(x = response_2)
str(parsed_response_2)
parsed_response_1 %>%
  extract2(1) %>%
  extract(c("id_str", "name", "location", "description", "protected", "created_at", 
            "statuses_count", "followers_count", "friends_count", "favourites_count", 
            "verified", "geo_enabled"))
parsed_response_2 %>%
  use_series(data)

# querying full posts with exception handling and additional parameters -----------------
posts <- try(httr::RETRY(verb = "GET",
                         url = "https://api.twitter.com/1.1/statuses/user_timeline.json?",
                         query = list(user_id = parsed_response_1[[1]]$id_str, 
                                      trim_user = "true",
                                      tweet_mode = "extended", # important, otherwise shortened
                                      count = 200), # important, no more than 200 with one request,
                         # default is 20
                         config = signature,
                         times = 100,
                         quite = FALSE,
                         terminate_on = c(200, 304, 400, 401, 403, 404, 406, 410, 422, 429)))
parsed_posts <- posts %>%
  httr::content() %>%
  purrr::map_dfr(extract, c("id_str", "full_text"))
parsed_retweets <- posts %>%
  httr::content() %>%
  purrr::map(extract("retweeted_status")) %>%
  purrr::map_dfr(extract, "full_text")
parsed_posts$retweet <- str_detect(parsed_posts$full_text, "^RT ")
position <- which(parsed_posts$retweet)
parsed_posts$retweet_text <- NA
parsed_posts$retweet_text[position] <- parsed_retweets$full_text
parsed_posts$full_text <- ifelse(str_detect(parsed_posts$full_text, "^RT "), 
                                 parsed_posts$retweet_text, 
                                 parsed_posts$full_text)

# querying the next page ----------------------------------------------------------------
more_posts <- try(httr::RETRY(verb = "GET",
                              url = "https://api.twitter.com/1.1/statuses/user_timeline.json?",
                              query = list(user_id = parsed_response_1[[1]]$id_str, 
                                           trim_user = "true",
                                           tweet_mode = "extended", 
                                           count = 200,
                                           max_id = tail(parsed_posts$id_str, 1)), # pagination
                              config = signature,
                              times = 100,
                              quite = FALSE,
                              terminate_on = c(200, 304, 400, 401, 403, 404, 406, 410, 422, 429)))
more_parsed_posts <- more_posts %>%
  httr::content() %>%
  purrr::map_dfr(extract, c("id_str", "full_text"))
more_parsed_retweets <- more_posts %>%
  httr::content() %>%
  purrr::map(extract("retweeted_status")) %>%
  purrr::map_dfr(extract, "full_text")



more_parsed_posts$full_text <- ifelse(str_detect(more_parsed_posts$full_text, "^RT "), 
                                 more_parsed_retweets$full_text, 
                                 more_parsed_posts$full_text)

# as in prior sessions, you can further wrap this code in a loop or within map to scale
# up and query posts of several users, whereby the user_id or screen_name is looped or
# mapped over.

# Just don't forget two things:
#   (1) add an appropriate Sys.sleep() after every call
#   (2) keep track of your rate limit via
#           x-rate-limit-remaining and x-rate-limit-reset (see above)
#           - after every call record the current rate limit
#           - check before every call if the rate limit is larger than 1
#           - if the rate limit is exhausted, apply Sys.sleep() until the rate limit is
#             reset


#### ACCESSING THE FACE++ API ===========================================================

# get US House members portrais ---------------------------------------------------------
# install.packages("legislatoR")
library(legislatoR)
portraits <- dplyr::semi_join(x = legislatoR::get_core(legislature = "usa_house"),
                              y = filter(legislatoR::get_political(legislature = "usa_house"),
                                         session == 116),
                              by = "pageid") %>%
  left_join(y = legislatoR::get_portrait(legislature = "usa_house"),
            by = "pageid") %>%
  filter(!is.na(image_url)) %>%
  dplyr::select(name, image_url)

# assign API credentials ----------------------------------------------------------------
api_key <- "xxxxxxxxxxxxxxxxxx" # replace with your API key
api_secret <- "xxxxxxxxxxxxxxxxxx" # replace with your API secret


# access using POST ---------------------------------------------------------------------
response_single <- httr::POST(url = "https://api-us.faceplusplus.com/facepp/v3/detect",
                              query = list(api_key = api_key,
                                           api_secret = api_secret,
                                           image_url = portraits$image_url[9],
                                           return_attributes = "gender,age,emotion"))
response_single %>% httr::content() %>%
  use_series(faces) %>%
  extract2(1) %>%
  use_series(attributes) %>%
  extract(c("age","gender","emotion")) %>%
  unlist
browseURL(portraits$image_url[9])

# applying an API function to several portraits -----------------------------------------
facialRecognition <- function(image_url, delay) {
  response <- try(httr::RETRY(verb = "POST",
                              url = ,"https://api-us.faceplusplus.com/facepp/v3/detect",
                              query = list(api_key = api_key,
                                           api_secret = api_secret,
                                           image_url = image_url,
                                           return_attributes = "age,gender,emotion")),
                  silent = FALSE)
  response <- response %>% httr::content() %>%
    use_series(faces) %>%
    extract2(1) %>%
    use_series(attributes) %>%
    extract(c("age","gender","emotion")) %>%
    unlist
  pb$tick()
  Sys.sleep(delay)
  return(response)
}


pb <- progress_bar$new(total = length(portraits$image_url[1:10]))
response_several <- portraits$image_url[1:10] %>%
  map_dfr(facialRecognition, delay = 1)
View(response_several)
