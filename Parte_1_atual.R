################################################################################
## script formulado para o Minicurso SDM
## Bragança - 17 à 19/05/23
# Marcelo Leandro Bueno - marcelo.bueno@uems.br
# Valéria Flávia Batista da sival - vfb_silva@uems.br
# Vanessa Pontara - vanessapontara@uems.br
# Apoio: projeto ForestFisher/FUNDECT/Biodiversa
################################################################################

# salvar projeto


#--------------------------------------------
# PASSO 1 - Salvar o projeto e criar o diretório de trabalho
#--------------------------------------------

#podemos comecar limpando a area de trabalho (workspace)
rm(list = ls())

# verificar um diretório no Rstudio
getwd() #para abrir o diretório de trabalho

# direcionar um diretório de trabalho; pode usar o CRTL+SHIFT+H para abrir uma 
# janela e escolher a pasta
setwd("~/Desktop/Minicurso_Bragança")
#aqui o exemplo da pasta onde estão em meu computador

#verificar um diretorio novamente e ver se corresponde com o seu diret?rio 
#de trabalho especificado anteriormente
getwd()

#--------------------------------------------
# PASSO 2 - Instalando os pacotes
#--------------------------------------------

##carregar os pacotes necess?rios 
install.packages(c("rgbif", "spocc", "ENMeval", "mapdata", "dismo", "maptools", 
                   "maps", "mapdata", "raster", "biomod2", "gridExtra", 
                   "rasterVis", "rgdal", "ade4",  dep = TRUE)) 
#dep representa que voce vai carregar as dependencias dos pacotes, 
#que pode ser outro pacote também

##LEMBRANDO:
install.packages("rasterVis") 
#se for instalar um pacote apenas 
#Lembrar que e necessário as aspas para o nome do pacote
#Contudo, para carregar o pacote não é necessário

############################# OBS ##############################################
#Você também pode usar o modelo abaixo para baixar os pacotes. Ele e útil, 
#porque se o pacote já tem baixado ele so carrega pela função: require() 
#e não instala novamente

if(!require(biomod2)){ ## instalar o pacote dismo, caso necess?rio
  install.packages("biomod2")
  require(dismo)
}
################################################################################

#carregando os pacotes instalados
library(rgbif) #para acessar o GBIF 
library(ENMeval) #performe ENM
library(spocc) #Interface to Species Occurrence Data Sources
library(dismo) #implements a few species distribution models
library(maptools) #tools for the creation of detailed maps
library(mapdata) #Supplement to maps
library(maps) #Projection code and larger maps 
library(raster) #provides classes and functions to manipulate geographic (spatial) data
library(biomod2) #Functions for species distribution modeling
library(gridExtra) #provides useful extensions to the grid system
library(rasterVis) #Methods for enhanced visualization and interaction with raster data
library(rgdal) #Bindings for the 'Geospatial' Data Abstraction
require(ade4) #Analysis of Ecological Data

#para verificar quais pacotes estão carregados
search()

#--------------------------------------------
# PASSO 3 - Carregar dados bióticos
#--------------------------------------------
if(require(raster)){
  #abrir diretório onde tem o arquivo com os pontos
  setwd("~/Desktop/Minicurso_Bragança/dados_bioticos")
  pontos <- read.csv("pontos_species.csv", 
                     header=TRUE, sep= ",")
  pontos
  head(pontos) # head significa visualizar as primeiras 6 linhas
  dim(pontos) #dimensão dos dados
}

#--------------------------------------------
# PASSO 4 - #plotando os pontos no mapa e verificando sua distribuição
#--------------------------------------------
#plotando os pontos
data(wrld_simpl) # data que representa o mapa do mundo
projection(wrld_simpl) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")
plot(wrld_simpl)

plot(wrld_simpl, xlim=c(-90,-30), ylim=c(-60,10),axes=T, col="gray")
points(pontos$lon,pontos$lat, pch=16, col="blue", cex=0.5)
dev.off()

#ajustando melhor o mapa para os registros de ocorrência
plot(wrld_simpl, xlim=c(-80,-60), ylim=c(-60,10),axes=T, col="gray")
points(pontos$lon,pontos$lat, pch=20, col="red", cex=1)
dev.off()

#--------------------------------------------
# PASSO 5 - Baixar as camadas bioclimáticas do presente
#--------------------------------------------
setwd("~/Desktop/Minicurso_Bragança")
dir.create("dados_abioticos") #criar diretório que vai ser salvo 
dir.create("dados_abioticos/atual")
setwd("dados_abioticos/atual")
getwd() # para verificar se está com  o diretório certo


# Esta opção nos permite controlar quanto tempo precisamos para baixar os dados.
#Se o R demorar mais de 10 minutos (6000 segundos) para baixar os dados, ele irá parar
#a transferência. Aumente o tempo limite, se necessário.
options(timeout=6000)

# Download 2.5 res worldclim V 2.1
P_url<-"https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_5m_bio.zip"
download.file(P_url,destfile="wc2.1_5m_bio.zip")
atual_unzipped_layers <- unzip("wc2.1_5m_bio.zip")

tif <- list.files(patt = ".tif$")
tif

stacked <- stack(atual_unzipped_layers)
plot(stacked$wc2.1_5m_bio_1)
dev.off()

names(stacked) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(stacked)
stacked
plot(stacked$bio_1)
dev.off()

############################# OBS ##############################################
#se você precisar carregar a pasta depois de fechado o R
#listar os arquivos presentes no diretório usar abaixo

# CARREGAR A PASTA DOS ARQUIVOS QUE SER?O CARREGADOS
# ACIONAR A PASTA QUE TEM OS ARQUIVOS
setwd("~/Desktop/Minicurso_Bragança/dados_abioticos/atual")
tif <- list.files(patt = ".tif$")
tif

pres <- grep("bi", tif, value = T) #pres representa o nome para as camadas atual
pres

stacked <- stack(pres)
names(stacked) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(stacked)
stacked
plot(stacked$bio_1)
dev.off()


#--------------------------------------------
# PASSO 6 - cortar as camadas bioclimáticas do presente
#--------------------------------------------

#carregando o shapefile e cortando as camadas do presente
library(raster)
setwd("~/Desktop/Minicurso_Bragança/shapefile/Amazonian")
amaz <- shapefile("Amazon_limites.shp")
amaz  
plot(amaz, col = "yellow", axes = T)
dev.off()

##Criar a máscara para a bacia Amazônica
mask_amaz <- mask(stacked, amaz) #stacked são as camadas ambientais do presente
mask_amaz #são para verificar os limites de extens?es e informações
plot(mask_amaz$bio_19)
dev.off()

#Clipar para o limite para a bacia Amazônica
clip_amaz <- crop(mask_amaz, amaz)
clip_amaz
plot(clip_amaz$bio_18)
dev.off()

# Apenas para confirmar o antes e o depois do limite do recorte das camadas
par(mfrow = c(1, 2)) ##plotar para verificar o antes e depois do clip das camadas
plot(stacked[[1]]) #verificar a extensão antes do corte
plot(clip_amaz$bio_1)
dev.off() #apagar os mapas gerados

#voltar para um figura por quadro
par(mfrow = c(1, 1))


#--------------------------------------------
# PASSO 7  REMOVER A MULTICOLINEARIDADE
#--------------------------------------------
#install.packages("usdm")
library(usdm)

##primeiro ajustar a matriz dos pontos para remover coluna da esp?cie
head(pontos)
pontos$species
class(pontos)
coordinates(pontos) <- c("lon","lat")

vif_geral <- extract(clip_amaz,pontos)
head(vif_geral)
class(vif_geral)

df <- data.frame(vif_geral)

v <- vifstep(df)
v

vc <- vifcor(df, th=0.8)
vc

camadas_vif <- exclude(clip_amaz, vc) #mudar para v o vc se for optar pelo vifstep
camadas_vif
plot(camadas_vif$bio_18)
dev.off()

################################################################################

#--------------------------------------------
# PASSO 8  PREPARAR OS PACOTES PARA RODAR OS MODELOS
#-------------------------------------------
#install.packages("devtools",dep=T)
#library(devtools)

#devtools::install_github('babaknaimi/sdm')
install.packages("sdm", dep=T)
library(sdm)

#para instalar o rJava
#install.packages("xlsx", dependencies = TRUE)
#https://java.com/en/download/manual.jsp    #para instalar o 64
#https://pt.stackoverflow.com/questions/371236/erro-na-instala%C3%A7%C3%A3o-do-pacote-xlsx


#ATEN??O com o pacote rJava
install.packages("rJava")
library(rJava)

#se nãoo abriu o rJava, rodar essa função abaixo, senãoo ignorar
# if(Sys.getenv("JAVA_HOME")!=""){
#   Sys.setenv(JAVA_HOME="")
# }

#ATEN??O ABAIXO SERVE PARA CARREGAR O ALGORITMO MAXENT
#para instalar o Maxent se for preciso
utils::download.file(url="https://raw.githubusercontent.com/mrmaxent/Maxent/master/ArchivedReleases/3.3.3k/maxent.jar", 
                     destfile = paste0(system.file("java", package = "dismo"), 
                                       "/maxent.jar"), mode = "wb")


#--------------------------------------------
# PASSO 9 AJUSTAR OS DADOS PARA OS MODELOS
#--------------------------------------------

#Deve carregar os pontos novamente
setwd("~/Desktop/Minicurso_Bragança/dados_bioticos")
pontos <- read.csv("pontos_species.csv", 
                   header=T, sep= ",")
pontos
head(pontos)
dim(pontos)

# primeiro ajustar a matriz dos pontos para remover coluna da esp?cie
head(pontos)
pontos$species
head(pontos)
class(pontos)
coordinates(pontos) <- c("lon","lat")
class(pontos)
head(pontos)

#--------------------------------------------
# PASSO 10 RODAR OS MODELOS
#--------------------------------------------
library(sdm)
#preparar o pontos
modelo <- sdmData(formula = species~.,
                  train = pontos,
                  predictors = camadas_vif,
                  bg=list(n=1000, method="gRandom",
                          remove=TRUE))

# camadas_vif representa o arquivo 
# das camadas ambientais do presente cortadas do passo 8 
# modelo1

#preparar os algoritmos
getmethodNames()#para escolher os algoritmos

modelos_geral <- sdm(Laetia_corymbulosa~.,modelo,
                     methods=c("maxent","rf", "glm"),
                     replication="sub", test.p=25, n=3)

#exemplo de uso do K-folds
#modelos_geral <- sdm(Laetia_corymbulosa~.,modelo1, 
#                     methods=c("maxent","rf", "glm"),
#                     replication=c('cv'),cv.folds=5,n=10)


modelos_geral

gui(modelos_geral) #para verificar os resultados perante os algoritmos

#Calcular a importância das variáveis
install.packages(ggplot2, dep=T)
library(ggplot2)

varimp <- getVarImp(modelos_geral)
plot(varimp, col="gray")
dev.off()

################################################################################

#--------------------------------------------
# PASSO 11 FAZER O ENSEMBLE DOS MODELOS
#--------------------------------------------

#salvar os modelos
setwd("~/Desktop/Minicurso_Bragança")
dir.create("modelos") #criar diretório que vai ser salvo 
dir.create("modelos/atual")
setwd("modelos/atual")
getwd() # para verificar se está com  o diretório certo

##PRESENTE

modelo_atual <- predict(modelos_geral, camadas_vif,"atual.grd")

names(modelo_atual)
plot(modelo_atual$id_1.sp_1.m_maxent.re_subs) # aqui para evidenciar no #plot vários modelos
dev.off()

# #fazer o emsemble
# #fazer o emsemble dos modelos

if(require(raster)){
  ensemble_modelo_atual <- ensemble(modelos_geral, modelo_atual,
                                    filename = 'ensemble_atual.tif',
                                    setting=list(method='weighted',
                                                 stat="TSS", opt=2))
  plot(ensemble_modelo_atual)
}

################################################################################