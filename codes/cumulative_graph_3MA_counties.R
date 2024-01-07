#Code to make a cumulative graph for 3 MA counties using CDC data 

library(arrow)
library(data.table)
library(ggplot2)
library(dplyr)

dat<-fread("./data/cdc_3masscounties.csv")
dat$date2<-as.Date(ISOdate(year = dat$year,
                           month = dat$month,
                           day = dat$day))
dat_short<-subset(dat,year<2022|(year==2022 & month<7))

plot1<-ggplot(dat_short,aes(date2,group=1))+geom_line(aes(y=fracMIDDLESEX,color="Middlesex"))+
  geom_line(aes(y=fracNORFOLK,color="Norfolk"))+geom_line(aes(y=fracSUFFOLK,color="Suffolk"))+
  ggtitle("Cumulative Cases Per Capita: CDC Data")+
  labs(x ="Date",y="Cumulative Reported Cases per Capita")+    
 # geom_vline(xintercept = as.numeric(as.Date("2022-03-03")), linetype="dashed", size = 0.1)+
 # geom_text(aes(x=as.Date('2022-03-03'), label="\nMarch 3", y=0.1), colour="red", angle=90)+
  scale_colour_manual(name="County",values=c("Middlesex"="#000000","Norfolk"="#009E73",
                                                       "Suffolk"="#D55E00"),limits = c("Suffolk", "Norfolk","Middlesex"))

png("./figures/plot_cumulative_3MA_counties.png")
print(plot1)
dev.off()