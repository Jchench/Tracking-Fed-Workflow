library(tidyverse)
library(ggthemes)
library(stringr)
library(ggforce)
library(ggExtra)
library(gridExtra)

# Read the data
folder_path <- "cleaned_csv/"

csv_files <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

d <- csv_files |> map_dfr(read_csv)

regs <- read_csv("Federal_Reserve_Board_Regulations.csv") %>%
  filter(`Part Number` < 254)

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
    str_detect(Change, regex("unknown", ignore_case = TRUE)) ~ "Unknown",
    TRUE ~ "Other"
  ))

# save out d2
write_csv(d2, file = "cleaned_changes.csv")

# Process activity data
activity <- d2 %>%
  mutate(Page = as.numeric(Page)) %>%
  group_by(Year) %>%
  transmute(Part.Number, Part, Page, approx_page_frac = Page / max(Page, na.rm = TRUE), Action) %>%
  filter(as.numeric(Part.Number) < 254, !is.na(Page))

# Create a list of all parts
all_parts <- sort(unique(c(activity$Part, regs$`Part Number`)))
activity$Part <- factor(activity$Part, levels = all_parts)

# Ensure there are no non-finite values
activity_clean <- activity %>%
  filter(is.finite(Year + approx_page_frac) & !is.na(Part))

# Ensure 'Part' is treated as a factor
activity_clean$Part <- as.factor(activity_clean$Part)

# Create the main scatter plot
plot_1 <- ggplot(activity_clean, aes(x = Year + approx_page_frac, y = Part, shape = Action, color = Action)) +
  geom_point(size = 2) +
  xlab("Year") +
  ylab("Part") +
  scale_y_discrete(limits = all_parts, expand = c(0.1, 0.1)) +
  scale_shape_manual(values = c("Addition" = 16, "Deletion" = 17, "Modification" = 18, "Unknown" = 19, "Other" = 15)) +
  scale_color_grey() +
  theme_tufte() +
  theme(legend.position = "bottom")

plot_1 + geom_rug(col = rgb(.5,0,0, alpha=.2))

# Create the individual plots
hist_top <- ggplot(activity_clean, aes(x = as.numeric(Year), fill = Action)) +
  geom_histogram(bins = 50, color = "black") +
  ggtitle("Activity by Part and Action Type") +
  scale_fill_grey() +
  theme_tufte() +
  theme(axis.ticks = element_blank(), 
        panel.background = element_blank(), 
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(),           
        axis.title.x = element_blank(), 
        axis.title.y = element_blank(),
        panel.grid = element_blank(), 
        legend.position = "none")

empty <- ggplot() + 
  geom_point(aes(1, 1), colour = "white") +
  theme(axis.ticks = element_blank(), 
        panel.background = element_blank(), 
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(),           
        axis.title.x = element_blank(), 
        axis.title.y = element_blank())

hist_right <- ggplot(activity_clean, aes(x = as.numeric(Part), fill = Action)) +
  geom_histogram(bins = 50, color = "black") +
  coord_flip() +
  scale_fill_grey() +
  theme_tufte() +
  theme(axis.ticks = element_blank(), 
        panel.background = element_blank(), 
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(),           
        axis.title.x = element_blank(), 
        axis.title.y = element_blank(),
        panel.grid = element_blank(),
        legend.position = "none")

grid.arrange(hist_top, empty, plot_1, hist_right, ncol = 2, nrow = 2, widths = c(4, 1), heights = c(1, 4))
