
require(data.table)
require(arrow)
require(corrplot)
require(tseries)
require(TTR)

dataset <- fread("southeast.csv")
dataset_rj <- dataset[state == "RJ"]
write_parquet(dataset_rj, "dados_rj.parquet")
rm(dataset, dataset_rj)

dataset <- read_parquet("dados_rj.parquet")
dataset[, index := NULL]
names(dataset) <- c("date", "hr", "prcp", "stp", "smax", "smin", "gbrd", 
                    "temp", "dewp", "tmax", "tmin", "dmax", "dmin", "hmax", 
                    "hmin", "hmdy", "wdct", "gust", "wdsp", "region", "prov", 
                    "wsnm", "inme", "lat", "lon", "elvt")

dataset_cor <- dataset[, c("date","prcp", "stp", "smax", "smin", "gbrd", 
                       "temp", "dewp", "tmax", "tmin", "dmax", "dmin", "hmax", 
                       "hmin", "hmdy", "wdct", "gust", "wdsp")]
is.na(dataset_cor) <- dataset_cor == -9999.0
dataset_corg <- na.omit(dataset_cor)
corrplot(cor(dataset_corg[, date := NULL]), method = "circle")
rm(dataset_corg)

dataset_cor1 <- na.omit(dataset_cor)
tmax <- TTR::runMean(dataset_cor1$tmax[], n=9)
par(mfrow=c(2,1))
plot.ts(tmax, main = "Temperatura máxima no tempo")
hist(tmax, main = "Temperatura máxima no tempo")
jarque.bera.test(na.omit(tmax))
rm(tmax)

tmin <- TTR::runMean(dataset_cor1$tmin[], n=9)
par(mfrow=c(2,1))
plot.ts(tmin, main = "Temperatura mínima no tempo")
hist(tmin, main = "Temperatura mínima no tempo")
jarque.bera.test(na.omit(tmin))
rm(tmin)

dmax <- TTR::runMean(dataset_cor1$dmax[], n=9)
plot.ts(dmax, main = "Temperatura do orvalho máxima no tempo")
hist(dmax, main = "Temperatura do orvalho máxima no tempo")
jarque.bera.test(na.omit(dmax))
rm(dmax)

dmin <- TTR::runMean(dataset_cor1$dmin[], n=9)
plot.ts(dmin, main = "Temperatura do orvalho mínima no tempo")
hist(dmin, main = "Temperatura do orvalho mínima no tempo")
jarque.bera.test(na.omit(dmin))
rm(dmin)

fit1 <- lm(formula = tmax ~ tmin + dmax + dmin + prcp + stp + gbrd, data = dataset_cor1)
summary(fit1)



