cat("\014") 
rm(list=ls())
library(parallel)
library(readxl)
library(lubridate)
source('./Codigos/Junta_Pmedia_Funcoes.R')
#---------------------------dados----------------------------------------------------
data_EC<-NULL
data_pmedia<-NULL
if(file.exists("./Junta_Pmedia_EC.txt")){
  suppressWarnings(namelist<-read.table("./Arq_Entrada/Junta_Pmedia_EC.txt",sep=":",header=FALSE))
  row.names(namelist)= namelist[,1]
  if (any(namelist == 'ECMWF')){data_EC<-as.Date(namelist['ECMWF',2],"%d/%m/%Y")}
  if (any(namelist == 'Pmedia')){data_pmedia<-as.Date(namelist['Pmedia',2],"%d/%m/%Y")}
}
if(is.null(data_pmedia)){data_pmedia<-Sys.Date()}

if(is.null(data_EC)){
  if(sum(wday(data_pmedia)==c(3,4,5))==1){
    data_EC<-(data_pmedia-(wday(data_pmedia)-2))} 
  else{
    if(sum(wday(data_pmedia)==c(6,7))==1){
      data_EC<-(data_pmedia-(wday(data_pmedia)-5))}
    else{data_EC<-(data_pmedia-(wday(data_pmedia)+2))}
    }
}

planilha<-read_xlsx("./Configuracao.xlsx",sheet = "Dados")

planilha[nrow(planilha)+1,1]<-"Jirau_tot"
planilha[nrow(planilha),2]<--9.26
planilha[nrow(planilha),3]<--64.66

planilha[nrow(planilha)+1,1]<-"Pimental_tot"
planilha[nrow(planilha),2]<--03.13
planilha[nrow(planilha),3]<--51.77

planilha[nrow(planilha)+1,1]<-"Amaru_tot"
planilha[nrow(planilha),2]<--12.60
planilha[nrow(planilha),3]<--69.12
#--------------------------Le Pmedia-------------------------------------------------
PMEDIA<-NULL
PMEDIA<-matrix(0,ncol=14,nrow=nrow(planilha))
for( i in 1:14){
  leitura<-read.table(paste0("./Arq_Entrada/Pmedia/","PMEDIA_p",format(data_pmedia, "%d%m%y"),"a",format((data_pmedia+i), "%d%m%y"),".dat"),header=F,stringsAsFactors	=F)
  lon_lat<- paste0(leitura[,1],"_",leitura[,2])
  for ( j in 1 : nrow(planilha)){
    l_l<-paste0(planilha$Longitude[j],"_",planilha$Latitude[j])
    linha<-which(lon_lat==l_l)
    PMEDIA[j,i]<-leitura[linha,3]
  }
}

#--------------------------Le EC-------------------------------------------------

ECMWF<-list()

for ( i in 1:10){
  ec<-matrix(0,ncol=45,nrow=nrow(planilha))
  arq_ecmwf<-read.table(paste0("./Arq_Entrada/ECMWF/ECMWF_m_",format(data_EC, "%d%m%y"),"_c",i,".dat"),header=F,stringsAsFactors	=F)
  lon_lat<- paste0(arq_ecmwf[,1],"_",arq_ecmwf[,2])
  for ( j in 1 : nrow(planilha)){
    l_l<-paste0(planilha$Longitude[j],"_",planilha$Latitude[j])
    linha<-tail(which(lon_lat==l_l),1)
    ec[j,1:45]<-as.numeric(arq_ecmwf[linha,3:47])
  }
  ECMWF[[i]]<-ec
}
#-------------------------- Roda em paralelo-----

clust <- makeCluster(5, type = 'PSOCK')

clusterExport(clust, varlist = c('junta_arq_unico','junta_arq_multi','data_pmedia','data_EC','planilha','PMEDIA','ECMWF','ajusta_lon'), envir = .GlobalEnv)

parLapply(clust,1:10, function(i)  junta_arq_multi(data_pmedia,data_EC,planilha,PMEDIA,ECMWF[[i]],paste0("PM.ECMWF",i-1)))

dir.create(paste0("./Arq_Saida/unico"))

parLapply(clust,1:10, function(i)  junta_arq_unico(data_pmedia,data_EC,planilha,PMEDIA,ECMWF[[i]],paste0("PM.ECMWF",i-1)))

stopCluster(clust)

