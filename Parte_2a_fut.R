
#--------------------------------------------
# PASSO 12 AJUSTAR AS CAMADAS DO FUTURO
#--------------------------------------------

#CENÁRIO 2041-2060 SSP245

#Salvar as camadas
setwd("~/Desktop/Minicurso-SDM-Portugal-main")
dir.create("dados_abioticos") #criar diretório que vai ser salvo 
dir.create("dados_abioticos/futuro")
dir.create("dados_abioticos/futuro/41_60")
setwd("dados_abioticos/futuro/41_60")
getwd() # para verificar se está com  o diretório certo


install.packages("geodata", dependencies = T)
library(geodata)

MIROC6_4160_245 <- geodata::cmip6_world(model='MIROC6', ssp='245', 
                                        time='2041-2060', var='bioc', 
                                        download=T, res=5, path='data')

MIROC6_4160_245

MIROC6_4160_245_st <- stack(MIROC6_4160_245)
MIROC6_4160_245_st

plot(MIROC6_4160_245_st$bio01)
dev.off()

names(stacked)
names(MIROC6_4160_245_st) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(MIROC6_4160_245_st)

camadas_vif 

MIROC6_4160_245_stacked <- stack(MIROC6_4160_245_st$bio_5,
                                 MIROC6_4160_245_st$bio_6,
                                 MIROC6_4160_245_st$bio_10,
                                 MIROC6_4160_245_st$bio_12,
                                 MIROC6_4160_245_st$bio_14,
                                 MIROC6_4160_245_st$bio_18)

MIROC6_4160_245_stacked 
plot(MIROC6_4160_245_stacked$bio_12)
plot(stacked$bio_12)
dev.off()

#cortar camadas
#carregando o shapefile e cortando as camadas do presente
library(raster)
setwd("~/Desktop/Minicurso_Bragança/shapefile/Amazonian")
amaz <- shapefile("Amazon_limites.shp")
amaz  
plot(amaz, col = "yellow", axes = T)
dev.off()

##Criar a máscara para a bacia Amazônica
mask_amaz_miroc_4160_245 <- mask(MIROC6_4160_245_stacked, amaz) #stacked são as camadas ambientais do presente
mask_amaz_miroc_4160_245  #são para verificar os limites de extensões e informações
plot(mask_amaz_miroc_4160_245$bio_18)
dev.off()

#Clipar para o limite para a bacia Amazônica
clip_amaz_miroc_4160_245 <- crop(mask_amaz_miroc_4160_245, amaz)
clip_amaz_miroc_4160_245
plot(clip_amaz_miroc_4160_245$bio_18)
dev.off()

setwd("~/Desktop/Minicurso_Bragança/variaveis_clip/future/41_60/miroc6")
terra::writeRaster(clip_amaz_miroc_4160,filename='clip_amaz_miroc_4160.grd')

#-----------------------------------

#CENÁRIO 2041-2060 SSP585

#Salvar as camadas
setwd("~/Desktop/Minicurso_Bragança")
dir.create("dados_abioticos") #criar diretório que vai ser salvo 
dir.create("dados_abioticos/futuro")
dir.create("dados_abioticos/futuro/41_60")
setwd("dados_abioticos/futuro/41_60")
getwd() # para verificar se está com  o diretório certo


MIROC6_4160_585 <- geodata::cmip6_world(model='MIROC6', ssp='585', 
                                        time='2041-2060', var='bioc', 
                                        download=T, res=5, path='miroc')

MIROC6_4160_585

MIROC6_4160_585_st <- stack(MIROC6_4160_585)
MIROC6_4160_585_st

plot(MIROC6_4160_585_st$bio02)
dev.off()

names(stacked)
names(MIROC6_4160_585_st) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(MIROC6_4160_585_st)

camadas_vif 

MIROC6_4160_585_stacked <- stack(MIROC6_4160_585_st$bio_5,
                                 MIROC6_4160_585_st$bio_6,
                                 MIROC6_4160_585_st$bio_10,
                                 MIROC6_4160_585_st$bio_12,
                                 MIROC6_4160_585_st$bio_14,
                                 MIROC6_4160_585_st$bio_18)

MIROC6_4160_585_stacked 
plot(MIROC6_4160_585_stacked$bio_12)
plot(stacked$bio_12)
dev.off()

#cortar camadas
#carregando o shapefile e cortando as camadas do presente
library(raster)
setwd("~/Desktop/Minicurso_Bragança/shapefile/Amazonian")
amaz <- shapefile("Amazon_limites.shp")
amaz  
plot(amaz, col = "yellow", axes = T)
dev.off()

##Criar a máscara para a bacia Amazônica
mask_amaz_miroc_4160_585 <- mask(MIROC6_4160_585_stacked, amaz) #stacked são as camadas ambientais do presente
mask_amaz_miroc_4160_585  #são para verificar os limites de extensões e informações
plot(mask_amaz_miroc_4160_585$bio_18)
dev.off()

#Clipar para o limite para a bacia Amazônica
clip_amaz_miroc_4160_585 <- crop(mask_amaz_miroc_4160_585, amaz)
clip_amaz_miroc_4160_585
plot(clip_amaz_miroc_4160_585$bio_18)
dev.off()


################################################################################

#-----------------------------------------------------
# PASSO 13 RODAR OS MODELOS PARA O FUTURO 2041 - 2060
#-----------------------------------------------------

#salvar os modelos
setwd("~/Desktop/Minicurso_Bragança")
dir.create("modelos") #criar diretório que vai ser salvo 
dir.create("modelos/futuro")
dir.create("modelos/futuro/41_60")
setwd("modelos/futuro/41_60")
getwd() # para verificar se está com  o diretório certo


modelo_miroc_245_4160 <- predict(modelos_geral, 
                                 clip_amaz_miroc_4160_245,
                                 "modelo_miroc_4160_245.grd",
                                 overwrite=T)

names(modelo_miroc_245_4160)
plot(modelo_miroc_245_4160$id_1.sp_1.m_maxent.re_subs) # aqui para evidenciar no #plot v?rios modelos
dev.off()

#fazer o emsemble
ensemble_modelo_miroc_245_4160 <- ensemble(modelos_geral, 
                                           modelo_miroc_245_4160,
                                           filename = 'ensemble_modelo_miroc_245_4160.tif',
                                           setting=list(method='weighted',
                                                        stat="TSS", opt=2),
                                           overwrite=T)
plot(ensemble_modelo_miroc_245_4160)
dev.off()

par(mfrow=c(1,2))
plot(ensemble_modelo_atual)
plot(ensemble_modelo_miroc_245_4160)
dev.off()

par(mfrow=c(1,1))
dev.off()

#-------------------------------
#salvar os modelos
setwd("~/Desktop/Minicurso_Bragança")
dir.create("modelos") #criar diretório que vai ser salvo 
dir.create("modelos/futuro")
dir.create("modelos/futuro/41_60")
setwd("modelos/futuro/41_60")
getwd() # para verificar se está com  o diretório certo


modelo_miroc_585_4160 <- predict(modelos_geral, 
                                 clip_amaz_miroc_4160_585,
                                 "modelo_miroc_4160_585.grd",
                                 overwrite=T)

names(modelo_miroc_585_4160)
plot(modelo_miroc_585_4160$id_1.sp_1.m_maxent.re_subs) # aqui para evidenciar no #plot v?rios modelos
dev.off()

#fazer o emsemble
ensemble_modelo_miroc_585_4160 <- ensemble(modelos_geral, modelo_miroc_585_4160,
                                           filename = 'ensemble_modelo_miroc_585_4160.tif',
                                           setting=list(method='weighted',
                                                        stat="TSS", opt=2),
                                           overwrite=T)
plot(ensemble_modelo_miroc_585_4160)
dev.off()

par(mfrow=c(1,2))
plot(ensemble_modelo_atual)
plot(ensemble_modelo_miroc_585_4160)
dev.off()

par(mfrow=c(1,1))
dev.off()

################################################################################

#CENÁRIO 2081-2100 SSP245

#Salvar as camadas
setwd("~/Desktop/Minicurso-SDM-Portugal-main")
dir.create("dados_abioticos") #criar diretório que vai ser salvo 
dir.create("dados_abioticos/futuro")
dir.create("dados_abioticos/futuro/81_100")
setwd("dados_abioticos/futuro/81_100")
getwd() # para verificar se está com  o diretório certo




MIROC6_81100_245 <- geodata::cmip6_world(model='MIROC6', ssp='245', 
                                         time='2081-2100', var='bioc', 
                                         download=T, res=5, path='miroc')

MIROC6_81100_245

MIROC6_81100_245_st <- stack(MIROC6_81100_245)
MIROC6_81100_245_st

plot(MIROC6_81100_245_st$bio01)
dev.off()

names(stacked)
names(MIROC6_81100_245_st) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(MIROC6_81100_245_st)

camadas_vif 

MIROC6_81100_245_stacked <- stack(MIROC6_81100_245_st$bio_5,
                                  MIROC6_81100_245_st$bio_6,
                                  MIROC6_81100_245_st$bio_10,
                                  MIROC6_81100_245_st$bio_12,
                                  MIROC6_81100_245_st$bio_14,
                                  MIROC6_81100_245_st$bio_18)

MIROC6_81100_245_stacked 
plot(MIROC6_81100_245_stacked$bio_12)
plot(stacked$bio_12)
dev.off()

#cortar camadas
#carregando o shapefile e cortando as camadas do presente
library(raster)
setwd("~/Desktop/Minicurso_Bragança/shapefile/Amazonian")
amaz <- shapefile("Amazon_limites.shp")
amaz  
plot(amaz, col = "yellow", axes = T)
dev.off()

##Criar a máscara para a bacia Amazônica
mask_amaz_miroc_81100_245 <- mask(MIROC6_81100_245_stacked, amaz) #stacked são as camadas ambientais do presente
mask_amaz_miroc_81100_245  #são para verificar os limites de extensões e informações
plot(mask_amaz_miroc_81100_245$bio_18)
dev.off()

#Clipar para o limite para a bacia Amazônica
clip_amaz_miroc_81100_245 <- crop(mask_amaz_miroc_81100_245, amaz)
clip_amaz_miroc_81100_245
plot(clip_amaz_miroc_81100_245$bio_18)
dev.off()


#-----------------------------------

#CENÁRIO 2081-2100 SSP585

#Salvar as camadas
setwd("~/Desktop/Minicurso-SDM-Portugal-main")
dir.create("dados_abioticos") #criar diretório que vai ser salvo 
dir.create("dados_abioticos/futuro")
dir.create("dados_abioticos/futuro/81_100")
setwd("dados_abioticos/futuro/81_100")
getwd() # para verificar se está com  o diretório certo


MIROC6_81100_585 <- geodata::cmip6_world(model='MIROC6', ssp='585', 
                                         time='2081-2100', var='bioc', 
                                         download=T, res=5, path='miroc',
                                         overwrite=T)

MIROC6_81100_585

MIROC6_81100_585_st <- stack(MIROC6_81100_585)
MIROC6_81100_585_st

plot(MIROC6_81100_585_st$bio02)
dev.off()

names(stacked)
names(MIROC6_81100_585_st) <- c(paste0("bio_", 1:9), paste0("bio_", 10:19))
names(MIROC6_81100_585_st)

camadas_vif 

MIROC6_81100_585_stacked <- stack(MIROC6_81100_585_st$bio_5,
                                  MIROC6_81100_585_st$bio_6,
                                  MIROC6_81100_585_st$bio_10,
                                  MIROC6_81100_585_st$bio_12,
                                  MIROC6_81100_585_st$bio_14,
                                  MIROC6_81100_585_st$bio_18)

MIROC6_81100_585_stacked 
plot(MIROC6_81100_585_stacked$bio_12)
plot(stacked$bio_12)
dev.off()

#cortar camadas
#carregando o shapefile e cortando as camadas do presente
library(raster)
setwd("~/Desktop/Minicurso_Bragança/shapefile/Amazonian")
amaz <- shapefile("Amazon_limites.shp")
amaz  
plot(amaz, col = "yellow", axes = T)
dev.off()

##Criar a máscara para a bacia Amazônica
mask_amaz_miroc_81100_585 <- mask(MIROC6_81100_585_stacked, amaz) #stacked são as camadas ambientais do presente
mask_amaz_miroc_81100_585  #são para verificar os limites de extensões e informações
plot(mask_amaz_miroc_81100_585$bio_18)
dev.off()

#Clipar para o limite para a bacia Amazônica
clip_amaz_miroc_81100_585 <- crop(mask_amaz_miroc_81100_585, amaz)
clip_amaz_miroc_81100_585
plot(clip_amaz_miroc_81100_585$bio_18)
dev.off()


################################################################################

#-----------------------------------------------------
# PASSO 13 RODAR OS MODELOS PARA O FUTURO 2041 - 2060
#-----------------------------------------------------

#salvar os modelos
setwd("~/Desktop/Minicurso_Bragança")
dir.create("modelos") #criar diretório que vai ser salvo 
dir.create("modelos/futuro")
dir.create("modelos/futuro/81_100")
setwd("modelos/futuro/81_100")
getwd() # para verificar se está com  o diretório certo


modelo_miroc_245_81100 <- predict(modelos_geral, clip_amaz_miroc_81100_245,
                                  "modelo_miroc_81100_245.grd")

names(modelo_miroc_245_81100)
plot(modelo_miroc_245_81100$id_1.sp_1.m_maxent.re_subs) # aqui para evidenciar no #plot v?rios modelos
dev.off()

#fazer o emsemble
ensemble_modelo_miroc_245_81100 <- ensemble(modelos_geral, modelo_miroc_245_81100,
                                            filename = 'ensemble_modelo_miroc_245_81100.tif',
                                            setting=list(method='weighted',
                                                         stat="TSS", opt=2))
plot(ensemble_modelo_miroc_245_81100)
dev.off()

par(mfrow=c(1,2))
plot(ensemble_modelo_atual)
plot(ensemble_modelo_miroc_245_81100)
dev.off()

par(mfrow=c(1,1))
dev.off()

#-------------------------------
#salvar os modelos
setwd("~/Desktop/Minicurso_Bragança")
dir.create("modelos") #criar diretório que vai ser salvo 
dir.create("modelos/futuro")
dir.create("modelos/futuro/81_100")
setwd("modelos/futuro/81_100")
getwd() # para verificar se está com  o diretório certo


modelo_miroc_585_81100 <- predict(modelos_geral, clip_amaz_miroc_81100_585,
                                  "modelo_miroc_81100_585.grd")

names(modelo_miroc_585_81100)
plot(modelo_miroc_585_81100$id_1.sp_1.m_maxent.re_subs) # aqui para evidenciar no #plot v?rios modelos
dev.off()

#fazer o emsemble
ensemble_modelo_miroc_585_81100 <- ensemble(modelos_geral, modelo_miroc_585_81100,
                                            filename = 'ensemble_modelo_miroc_585_81100.tif',
                                            setting=list(method='weighted',
                                                         stat="TSS", opt=2))
plot(ensemble_modelo_miroc_585_81100)
dev.off()

par(mfrow=c(1,2))
plot(ensemble_modelo_atual)
plot(ensemble_modelo_miroc_585_81100)
dev.off()

par(mfrow=c(1,1))
dev.off()

################################################################################
