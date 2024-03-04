#Code to make a map of Mass school districts
#This code creates Figure 1 in the paper. This shows a control group of districts <50km from Boston
#Change the 50km to 65 or 80 km as needed to replicate Figures S1 and S2 in the supplementary file.


library(sf)
x=st_read(".\\data\\district shapefiles\\SCHOOLDISTRICTS_POLY.shp")
y <- read.csv(".\\data\\district_data_for_map2.csv", colClasses = c(ORG8CODE = "character"))
dat=merge(x, y, by = "ORG8CODE",all.x=T)
dat$nejm[is.na(dat$nejm)]=0
plot(dat['nejm']) #This replicates the original Cowger et al map
dat$km=as.numeric(dat$km)
dat$boschel=ifelse(dat$district=="Boston"|dat$district=="Chelsea",1,0)
dat$boschel[is.na(dat$boschel)]=0
dat$km[is.na(dat$km)]=200 #missing distances, setting to max as these are all far away
dat$km[dat$ORG8CODE=="06980000"]=49 #Manchester by the sea, wrong match

dat$cols50=0
dat$cols50[dat$boschel==1]=1 #Boston, Chelsea
dat$cols50[dat$nejm==1 & dat$boschel==0]=2 #Rest of NEJM sample
dat$cols50[dat$nejm==0 & dat$km<50]=3 #Other districts within 50km
dat$cols50[dat$nejm==0 & dat$km>50]=4 #Rest of state
dat$cols50[dat$fulldat==0]=5 # 70 districts with >10 weeks of zero cases

districtPalette <- c("blue","purple","green","yellow","gray")
dat$discolor[dat$cols50==1]="blue"
dat$discolor[dat$cols50==2]="purple"
dat$discolor[dat$cols50==3]="green"
dat$discolor[dat$cols50==4]="yellow"
dat$discolor[dat$cols50==5]="gray"
dat$distype[dat$cols50==1]="Boston, Chelsea"
dat$distype[dat$cols50==2]="NEJM control districts"
dat$distype[dat$cols50==3]="Other districts < 50km"
dat$distype[dat$cols50==4]="Rest of State"
dat$distype[dat$cols50==5]="Districts with insufficient data"
shp_df <- raster::as.data.frame(dat)
shp_df$distype=as.factor(shp_df$distype)
shp_df$distype<-factor(shp_df$distype,levels=c("Boston, Chelsea","Cowger et al control districts","Other districts < 50km","Rest of State","Districts with insufficient data"))


png(file = 'massmap50b.png')
plot(dat['cols50'],main="",col=dat$discolor)
legend("bottomleft",
       legend=levels(shp_df$distype), 
       fill=districtPalette,
       box.lty=0)
dev.off()



