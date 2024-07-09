library(tidyverse)
library(ggthemes)

# Read the data
d <- read_csv("cleaned_csv/1964_1972.csv")
regs <- read_csv("Federal_Reserve_Board_Regulations.csv") %>%
  filter(`Part Number` < 250)

# Separate Part Numbers and filter data
d2 <- d %>%
  separate(Part.Number, into = c("Part.Number.Start", "Part.Number.End"), sep = "-", remove = FALSE, fill = "right") %>%
  separate(Part.Number.Start, into = c("Part", "Subpart"), sep = "\\.", remove = FALSE, fill = "right")

# Add Action column to distinguish types of changes
d2 <- d2 %>%
  mutate(Action = case_when(
    str_detect(Change, regex("delete|removal|repeal", ignore_case = TRUE)) ~ "Deletion",
    str_detect(Change, regex("add|addition|new", ignore_case = TRUE)) ~ "Addition",
    str_detect(Change, regex("modify|amend|change", ignore_case = TRUE)) ~ "Modification",
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
option_1 <- 
  ggplot(activity, aes(x = Year + approx_page_frac, y = Part, color = Action, shape = Action)) +
  geom_point(size = 3) +
  theme_tufte() +
  ggtitle("Activity by Part and Action Type") +
  xlab("Year") +
  scale_y_discrete(limits = all_parts) +
  scale_color_manual(values = c("Addition" = "green", "Deletion" = "red", "Modification" = "blue", "Other" = "grey")) +
  scale_shape_manual(values = c("Addition" = 16, "Deletion" = 17, "Modification" = 18, "Other" = 15))

option_1

option_2 <- 
  ggplot(activity, aes(x = Year + approx_page_frac, y = Part, shape = Action, size = Action)) +
  geom_point(alpha = 0.5) +
  theme_tufte() +
  ggtitle("Activity by Part and Action Type") +
  xlab("Year") +
  scale_y_discrete(limits = all_parts) +
  scale_shape_manual(values = c("Addition" = 16, "Deletion" = 17, "Modification" = 18, "Other" = 15)) +
  scale_size_manual(values = c("Addition" = 3, "Deletion" = 4, "Modification" = 5, "Other" = 2))

option_2

option_3 <- 
  ggplot(activity, aes(x = Year + approx_page_frac, y = Part, shape = Action, size = Action)) +
  geom_point(size = 2) +
  theme_tufte() +
  ggtitle("Activity by Part and Action Type") +
  xlab("Year") +
  scale_y_discrete(limits = all_parts) +
  scale_shape_manual(values = c("Addition" = 3, "Deletion" = 4, "Modification" = 19, "Other" = 18))

option_3

# Get unique changes where Subpart is NA
unique_changes <- d2 %>%
  filter(is.na(Subpart)) %>%
  pull(Change) %>%
  unique()
