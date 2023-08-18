junta_arq_unico<- function(data_pmedia,data_EC,planilha,pmedia,ecmwf,sigla){
  library(lubridate)
  library(gdata)
  diff<- as.numeric(data_pmedia-data_EC)
  arq<-paste0("./Arq_Saida/unico/",sigla,"_p",format(data_pmedia, format="%d%m%y"),"a",format((data_pmedia+45), format="%d%m%y"),".dat")
  file.create(arq)
  for( j in 1:nrow(planilha)){  
    valor<-NULL
    for( i in 1:14){valor[i]<- pmedia[j,i]}
    for( i in (15+diff):45){valor[i-diff]<- ecmwf[j,i]}
    for( i in (46-diff):45){valor[i]<-ecmwf[j,45]}
    
    vv<-as.matrix(t(c(planilha$Longitude[j],planilha$Latitude[j],valor)))
    write.fwf(vv, file=arq, append=TRUE, quote=FALSE, sep=" ", na="",rownames=FALSE, colnames=FALSE, rowCol=NULL, justify="right",
              formatInfo=FALSE, quoteInfo=TRUE, width=6, eol="\n",qmethod=c("escape", "double"),  scientific=FALSE)
    }
}

junta_arq_multi<- function(data_pmedia,data_EC,planilha,pmedia,ecmwf,sigla){
  library( lubridate)
  diff<- as.numeric(data_pmedia-data_EC)
  dir.create(paste0("./Arq_Saida/",sigla))

      # -------------------------------------- bloco Pmedia -------------------------------------------------------------------
  for( i in 1:14){
    arq_t<-paste0("./Arq_Saida/",sigla,"/",sigla,"_p",format(data_pmedia, format="%d%m%y"),"a",format((data_pmedia+i), format="%d%m%y"),".dat")
    arq<- file( arq_t, "w")
    for( j in 1:nrow(planilha)){
      linha <- sprintf(
        "%-6s %6s %-6s\n",format(planilha$Longitude[j],nsmall=2),
        ajusta_lon(planilha$Latitude[j]),
        format(pmedia[j,i],nsmall=2))
      
      cat(linha, file = arq)
    }
    close(arq)
  }
  # -------------------------------------- bloco ECMWF -------------------------------------------------------------------
  for( i in (15+diff):45){
    arq_t<-paste0("./Arq_Saida/",sigla,"/",sigla,"_p",format(data_pmedia, format="%d%m%y"),"a",format((data_pmedia+(i-diff)), format="%d%m%y"),".dat")
    arq<- file( arq_t, "w")
    for( j in 1:nrow(planilha)){
      linha <- sprintf(
        "%-6s %6s %-6s\n",format(planilha$Longitude[j],nsmall=2),
        ajusta_lon(planilha$Latitude[j]),
        format(ecmwf[j,i],nsmall=2))
      
      cat(linha, file = arq)
    }
    close(arq)
  }
  
  for( i in (46-diff):45){
    arq_t<-paste0("./Arq_Saida/",sigla,"/",sigla,"_p",format(data_pmedia, format="%d%m%y"),"a",format((data_pmedia+(i)), format="%d%m%y"),".dat")
    arq<- file( arq_t, "w")
    for( j in 1:nrow(planilha)){
      
      linha <- sprintf(
        "%-6s %6s %-6s\n",format(planilha$Longitude[j],nsmall=2),
        ajusta_lon(planilha$Latitude[j]),
        format(ecmwf[j,45],nsmall=2))
      
      cat(linha, file = arq)
    }
    close(arq)
  } 
  
}

ajusta_lon<- function(lon){
  lon<-round(as.numeric(lon),2)
  parte_inteira<- trunc(lon)
  texto<-sprintf("%02d",as.integer(abs(parte_inteira)))
  if (lon<0){texto<-paste0("-",texto)}
  parte_decimal<-as.integer(round((abs(lon)-trunc(abs(lon)))*100,0))
  return(paste0(texto,".",sprintf("%02d",parte_decimal)))
}

