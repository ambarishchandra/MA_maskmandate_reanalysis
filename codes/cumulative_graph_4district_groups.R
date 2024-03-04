#Code to make a graph showing cumulative community cases per capita for the 4 groups of school districts studied by Cowger et al.


library(arrow)
library(data.table)
library(ggplot2)
library(dplyr)

dat4group<-fread("./data/4group_data.csv")
short4group<-subset(dat4group,year<2022|(year==2022 & month<7))


plot_4group<-ggplot(short4group,aes(reportdate,group=1))+geom_line(aes(y=frac0,color="Never"))+
  geom_line(aes(y=frac1,color="March 3"))+geom_line(aes(y=frac2,color="March 10"))+
  geom_line(aes(y=frac3,color="March 17"))+
  ggtitle("Cumulative Cases Per Capita")+
  labs(x ="Date",y="Cumulative Reported Cases per Capita")+    
  geom_vline(xintercept = as.numeric(as.Date("2022-03-03")), linetype="dashed", size = 0.1)+
  geom_text(aes(x=as.Date('2022-03-03'), label="\nMarch 3", y=0.1), colour="red", angle=90)+
  scale_colour_manual(name="Mandate End Date",values=c("Never"="#000000","March 3"="#009E73",
                                                       "March 10"="#0072B2","March 17"="#D55E00"),limits = c("Never", "March 17","March 3","March 10"))


pdf("plot_cumulative_4group.pdf")
print(plot_4group)
dev.off()


