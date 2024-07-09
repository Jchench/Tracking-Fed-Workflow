library(tidyverse)
library(ggthemes)
d = read_csv("1964_1972.csv")

regs =read_csv("Federal_Reserve_Board_Regulations.csv") %>%
  filter(`Part Number`<250)

d %>%
  select(-X) %>%
  #deal with part numbers like 215.1-215.6  
  separate(Part.Number,into=c("Part.Number.Start","Part.Number.End"),
           sep="\\-",remove=F)%>%
  filter(!is.na(Part.Number.End)) %>%
  View()

d %>%
  select(-X) %>%
  #deal with part numbers like 215.1-215.6  
  separate(Part.Number,into=c("Part.Number.Start","Part.Number.End"),
           sep="\\-",remove=F)%>%
  filter(is.na(Part.Number.Start))

d2 = d %>%
  select(-X) %>%
  #deal with part numbers like 215.1-215.6  
  separate(Part.Number,into=c("Part.Number.Start","Part.Number.End"),
           sep="\\-",remove=F,fill="right")%>%
  separate(Part.Number.Start,into=c("Part","Subpart"),sep="\\.",remove=F,
           fill="right")


d2 %>%
  filter(is.na(Subpart))

activity = d2 %>%
  mutate(Page=as.numeric(Page)) %>% 
  group_by(Year) %>%
  transmute(Part.Number,Part,Page,approx_page_frac=Page/max(Page,na.rm=T)) %>%
  filter(as.numeric(Part.Number)<250) %>%
  filter(!is.na(Page))

all_parts = sort(unique(c(activity$Part,regs$`Part Number`)))
activity$Part = factor(activity$Part,levels=all_parts)

#good start
ggplot(activity,aes(x=Year+approx_page_frac,y=Part)) + 
  geom_point(shape=4)+
  theme_tufte() +
  ggtitle("Activity by Part") +
  xlab("Year") +
  scale_y_discrete(limits=all_parts)

d2 %>%
  filter(is.na(Subpart)) %>%
  pull(Change) %>%
  unique()


