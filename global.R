# --- Shiny Library --- #

library(shiny)
library(shinyWidgets)
library(shinydashboard)

# --- Library used in the dashboard --- #
library(tidyverse)
library(lubridate)
library(data.table)
library(DT)
library(knitr)
library(glue)
library(scales)
library(plotly)
library(leaflet)
library(rgdal)
library(maps)

# --- Importing Data --- #

# Bristol Data
bristol_listing <- read.csv("assets/bristol-listings.csv") 
# London Boroughs (.json)
bristol_neigh <- readOGR("assets/bristol-neighbourhoods.geojson")


# Edinburgh Data
edinburgh_listing <- read.csv("assets/edinburgh-listings.csv") 
# London Boroughs (.json)
edinburgh_neigh <- readOGR("assets/edinburgh-neighbourhoods.geojson")


# Greater Manchester Data
manchester_listing <- read.csv("assets/manchester-listings.csv") 
# London Boroughs (.json)
manchester_neigh <- readOGR("assets/manchester-neighbourhoods.geojson")


# London Data
london_listing <- read.csv("assets/london-listings.csv") 
# London Boroughs (.json)
london_neigh <- readOGR("assets/london-neighbourhoods.geojson")



# --- Data Wrangling --- #
bristol_listing <- bristol_listing %>% 
  mutate(
    host_name = as.factor(host_name),
    neighbourhood = as.factor(neighbourhood),
    room_type = as.factor(room_type),
    last_review = ymd(last_review),
    year = year(last_review),
    month = month(last_review),
    day = day(last_review),
    yearmo = format_ISO8601(last_review, precision = "ym")
  )

edinburgh_listing <- edinburgh_listing %>% 
  mutate(
    host_name = as.factor(host_name),
    neighbourhood = as.factor(neighbourhood),
    room_type = as.factor(room_type),
    last_review = ymd(last_review),
    year = year(last_review),
    month = month(last_review),
    day = day(last_review),
    yearmo = format_ISO8601(last_review, precision = "ym")
  )


manchester_listing <- manchester_listing %>% 
  mutate(
    host_name = as.factor(host_name),
    neighbourhood = as.factor(neighbourhood),
    room_type = as.factor(room_type),
    last_review = ymd(last_review),
    year = year(last_review),
    month = month(last_review),
    day = day(last_review),
    yearmo = format_ISO8601(last_review, precision = "ym")
  )


london_listing <- london_listing %>% 
  mutate(
    host_name = as.factor(host_name),
    neighbourhood = as.factor(neighbourhood),
    room_type = as.factor(room_type),
    last_review = ymd(last_review),
    year = year(last_review),
    month = month(last_review),
    day = day(last_review),
    yearmo = format_ISO8601(last_review, precision = "ym")
  )