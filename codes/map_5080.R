#Code to make a map of Mass school districts
#This code creates Figure 1 in the paper. This shows a control group of districts <50km from Boston
#Change the 50km to 65 or 80 km as needed to replicate Figures S1 and S2 in the supplementary file.


library(sf)
x=st_read(".\\data\\shape files\\SCHOOLDISTRICTS_POLY.shp")
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


# Adding another set of districts in another colour (red), within 80 km of Boston


dat$colsfull=0
dat$colsfull[dat$boschel==1]=1 #Boston, Chelsea
dat$colsfull[dat$nejm==1 & dat$boschel==0]=2 #Rest of NEJM sample
dat$colsfull[dat$nejm==0 & dat$km<50]=3 #Other districts within 50km
dat$colsfull[dat$nejm==0 & dat$km>50 & dat$km<80]=4 #Other districts within 80km
dat$colsfull[dat$nejm==0 & dat$km>80]=5 #Rest of state
dat$colsfull[dat$fulldat==0]=6 # 70 districts with >10 weeks of zero cases


districtPalette <- c("blue","purple","green","red","yellow","gray")
dat$discolor[dat$colsfull==1]="blue"
dat$discolor[dat$colsfull==2]="purple"
dat$discolor[dat$colsfull==3]="green"
dat$discolor[dat$colsfull==4]="red"
dat$discolor[dat$colsfull==5]="yellow"
dat$discolor[dat$colsfull==6]="gray"
dat$distype[dat$colsfull==1]="Boston, Chelsea"
dat$distype[dat$colsfull==2]="NEJM control districts"
dat$distype[dat$colsfull==3]="Other districts < 50km"
dat$distype[dat$colsfull==4]="Other districts < 80km"
dat$distype[dat$colsfull==5]="Rest of State"
dat$distype[dat$colsfull==6]="Districts with insufficient data"

shp_df <- raster::as.data.frame(dat)
shp_df$distype=as.factor(shp_df$distype)
shp_df$distype<-factor(shp_df$distype,levels=c("Boston, Chelsea","Cowger et al control districts","Other districts < 50km","Other districts >50, <80km","Rest of State","Districts with insufficient data"))



png(file = 'massmap5080.png')
plot(dat['colsfull'],main="",col=dat$discolor)
legend("bottomleft",
       legend=levels(shp_df$distype), 
       fill=districtPalette,
       box.lty=0)
dev.off()

png(file = 'massmap5080noleg.png',width=400, height=350,res=45)
par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
plot(dat['colsfull'],main="",col=dat$discolor)
title("Figure 1: School Districts in Massachusetts by study group, \nwith corresponding socioeconomic data", line = -6)
dev.off()




