library(tidyverse)

data <- 
  read_csv("cleaned_changes.csv")

categorize_year <- function(year) {
  if (year >= 1938 & year < 1949) {
    return(c(1938, 1949))
  } else if (year > 1949 & year < 1959) {
    return(c(1949, 1959))
  } else if (year > 1959 & year < 1963) {
    return(c(1959, 1963))
  } else if (year > 1963 & year < 1967) {
    return(c(1963, 1967))
  } else if (year > 1967 & year < 1968) {
    return(c(1967, 1968))
  } else {
    return(c(year, year + 1))
  }
}

data <- 
  data |> 
  select(Action, Part.Number, Year) |> 
  filter(str_detect(as.numeric(Part.Number), "^[0-9]+$")) |> 
  rowwise() |> 
  mutate(Year_Range = list(categorize_year(Year))) |> 
  unnest_wider(Year_Range, names_sep = "_") |> 
  rename(Year = Year, Next_Edition = Year_Range_2, Start_Year = Year_Range_1)

data <- 
  data |> 
  select(Action, Part.Number, Start_Year, Next_Edition) |> 
  rename(Year = Start_Year, Next.Edition = Next_Edition, 'CFR Part' = Part.Number)

write_csv(data, file = "actions.csv")
