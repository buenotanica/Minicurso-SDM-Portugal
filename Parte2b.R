#-------------------------------------------------------------------------------
#PASSO 14 BINARIZAR OS MAPAS E CALCULAR RETRAÇÀO E EXPANSÃO
#-------------------------------------------------------------------------------


############
# Presente
############

library(raster)
library(sdm)
df <- as.data.frame(modelo)
df
df <- data.frame(species=df$Laetia_corymbulosa,coordinates(modelo))
head(df)

xy <- as.matrix (df[,c("lon", "lat")])
head(xy)
p_atual <- raster::extract(ensemble_modelo_atual,xy)
head(p_atual)

env <- evaluates(df$species,p_atual)
env@statistics
env@threshold_based

th <- env@threshold_based$threshold[2]
th
pa_ensemble_atual <- raster(ensemble_modelo_atual)

#aqui no presente eu disse que onde ocorre é 1 e onde não ocorre é zero
pa_ensemble_atual[] <- ifelse(ensemble_modelo_atual[] >= th, 1, 0)

plot(pa_ensemble_atual)
dev.off()

#Salvar o mapa binario
setwd("~/Desktop/Minicurso-SDM-Portugal-main")
dir.create("dados_binarios") #criar diretório que vai ser salvo 
setwd("dados_binarios")
getwd() # para verificar se está com  o diretório certo

library(raster)
pa_atual<- writeRaster(pa_ensemble_atual,"pa_atual.tif")
plot(pa_atual)
dev.off()


#####################
# 2041-2060 SSP 245
#####################

library(raster)
library(sdm)
df <- as.data.frame(modelo)
df
df <- data.frame(species=df$Laetia_corymbulosa,coordinates(modelo))
head(df)

xy <- as.matrix (df[,c("lon", "lat")])
head(xy)
p_245_4160 <- raster::extract(ensemble_modelo_miroc_245_4160,xy)
head(p_245_4160)

env <- evaluates(df$species,p_245_4160)
env@statistics
env@threshold_based

th <- env@threshold_based$threshold[2]
th
pa_ensemble_245_4160 <- raster(ensemble_modelo_miroc_245_4160)

#aqui no presente eu disse que onde ocorre é 1 e onde não ocorre é zero
pa_ensemble_245_4160[] <- ifelse(ensemble_modelo_miroc_245_4160[] >= th, 1, 0)

plot(pa_ensemble_245_4160)
dev.off()

#Salvar o mapa binario
setwd("~/Desktop/Minicurso-SDM-Portugal-main")
dir.create("dados_binarios") #criar diretório que vai ser salvo 
setwd("dados_binarios")
getwd() # para verificar se está com  o diretório certo

library(raster)
pa_ensemble_245_4160<- writeRaster(pa_ensemble_245_4160,"pa_ensemble_245_4160.tif")
plot(pa_ensemble_245_4160)
dev.off()


#-------------------------------------------------------------------------------
# Retracao e expansao
#-------------------------------------------------------------------------------

# 2081-2100 SSP 585
####################

setwd("E:/Analises_dissertacao/New_models_ret_exp/Cerrado/Mapa_binario")
pres <- raster("pa_atual.tif")
projection(pres) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")

setwd("E:/Analises_dissertacao/New_models_ret_exp/Cerrado/Mapa_binario")
future_585_81100_t <- raster("pa_585_8110_cerrado.tif")
projection(future_585_81100_t) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")

pres <- pa_ensemble_atual
future <- pa_ensemble_245_4160

plot(pres)
plot(future)
dev.off()

chp <- future - pres
plot(chp, col=c("red", "gray", "blue","green")) #outro tipo de mapa
unique(chp)

#change_585_81100_t[] <- ifelse(pres[] == future_585_81100_t[],0,
#ifelse(pres[] > future_585_81100_t[],1,2))

change_245_4160 <- raster(pres)
change_245_4160[] <- ifelse(pres[] == future[], 0,
                            ifelse(pres[] > future[], -1,
                                   ifelse(future[]-pres[] == 1, 1,
                                          ifelse(future[]-pres[] == 2, 2, 3))))

change_245_4160

# Contar os pixels em cada categoria, incluindo os valores 2
count <- table(change_245_4160[])
# Exibir a contagem
count 

# Cria o gráfico de barras
barplot(count, 
        names.arg = c("-1", "0", "1", "2"),
        xlab = 'Change', 
        ylab = 'Number of pixels')

plot(change_245_4160,
     legend = F,
     col = c("red","darkgray", "blue", "green"), 
     axes = TRUE,
     main = "SSP245 2041-2060")

legend("bottomright",
       legend = c("Retraction", "unsuitable", "Stable", "Expansion"),
       fill = c("red","darkgray", "blue", "green"),
       border = F,
       bty = "n")


#Salvar o mapa binario
setwd("~/Desktop/Minicurso-SDM-Portugal-main/dados_binarios")
getwd()

change_245_4160_ta <- writeRaster(change_245_4160,
                                  "change_245_4160.tif")

table_change_245_4160_ta <- tapply(area(change_245_4160), 
                                   change_245_4160[], 
                                   sum) # Tabulating change

change_change_245_4160_ta <- as.data.frame(table_change_245_4160_ta)
change_change_245_4160_ta 
write.csv(change_change_245_4160_ta , "change_245_4160_ta.csv", row.names = F)
dev.off()
