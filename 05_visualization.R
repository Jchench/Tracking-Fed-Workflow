library(tidyverse)
library(ggthemes)
library(stringr)

# Read the data
folder_path <- "cleaned_csv/"

csv_files <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

d <- csv_files |> map_dfr(read_csv)

regs <- read_csv("Federal_Reserve_Board_Regulations.csv") %>%
  filter(`Part Number` < 250)

# Separate Part Numbers and filter data
d2 <- d %>%
  separate(Part.Number, into = c("Part.Number.Start", "Part.Number.End"), sep = "-", remove = FALSE, fill = "right") %>%
  separate(Part.Number.Start, into = c("Part", "Subpart"), sep = "\\.", remove = FALSE, fill = "right")

# Remove any numeric prefix followed by a hyphen from the Page column
d2 <- d2 %>%
  mutate(Page = str_remove(Page, "^\\d+-"))

# Add Action column to distinguish types of changes
d2 <- d2 %>%
  mutate(Action = case_when(
    str_detect(Change, regex("delete|remove|removal|repeal|revoke", ignore_case = TRUE)) ~ "Deletion",
    str_detect(Change, regex("add|addition|new|designate", ignore_case = TRUE)) ~ "Addition",
    str_detect(Change, regex("modify|modified|amend|change|revise|correct", ignore_case = TRUE)) ~ "Modification",
    TRUE ~ "Other"
  ))

# Process activity data
activity <- d2 %>%
  mutate(Page = as.numeric(Page)) %>%
  group_by(Year) %>%
  transmute(Part.Number, Part, Page, approx_page_frac = Page / max(Page, na.rm = TRUE), Action) %>%
  filter(as.numeric(Part.Number) < 250, !is.na(Page))

# Create a list of all parts
all_parts <- sort(unique(c(activity$Part, regs$`Part Number`)))
activity$Part <- factor(activity$Part, levels = all_parts)

# Plot the data
ggplot(activity, aes(x = Year + approx_page_frac, y = Part, shape = Action, size = Action)) +
  geom_point(alpha = 0.5, size = 2) +
  theme_tufte() +
  ggtitle("Activity by Part and Action Type") +
  xlab("Year") +
  scale_y_discrete(limits = all_parts) +
  scale_shape_manual(values = c("Addition" = 16, "Deletion" = 17, "Modification" = 18, "Other" = 15)) +
  scale_size_manual(values = c("Addition" = 3, "Deletion" = 4, "Modification" = 5, "Other" = 2))
