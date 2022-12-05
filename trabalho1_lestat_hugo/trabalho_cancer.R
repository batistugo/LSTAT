######################################
# Trabalho Lestat - Noplasias malignas
# Hugo Batista
######################################

require(readxl)
require(data.table)
require(ggplot2)

#dataset <- as.data.table(read_excel(path = "dados/dados5.xlsx", sheet = "obitos"))

fx <- c("0_a_1", "1_a_4", "5_a_9", "10_a_14", "15_a_19")

dataset_final <- data.table()
first <- TRUE

for (idade in fx) {
  
  dataset <- as.data.table(read_excel(paste0("dados/", idade, ".xlsx"), skip = 5L))
  names(dataset) <- c("univ", paste0(idade, "_", 1996L:2020L), paste0(idade, "_","total"))
  dataset[, univ := as.numeric(substr(univ, 1, 4))]
  dataset <- dataset[!is.na(univ)]
  dataset <- dataset[, lapply(.SD, function(x)(as.numeric(x)))]
  dataset[, paste0(idade, "_","total") := NULL]
  
  if(first){
    dataset_final <- dataset
    first <- FALSE
  } else{
    dataset_final <- merge(dataset_final, dataset, by = "univ")
  }

}
rm(dataset)

dataset_final <- melt(
  data = dataset_final, id.vars = "univ", variable.name = "ano_idade",
  value.name = "obitos"
)

dataset_final <- dataset_final[, .(obitos = sum(obitos, na.rm = TRUE)), by = .(univ, ano_idade)]
dataset_final1 <- copy(dataset_final)
dataset_final1 <- dataset_final1[, .(obitos = sum(obitos, na.rm = TRUE)), by = .(trunc(univ/100L), ano_idade)]
setnames(dataset_final1, "trunc", "univ")

dataset_final2 <- copy(dataset_final)
dataset_final2 <- dataset_final2[, .(obitos = sum(obitos, na.rm = TRUE)), by = .(trunc(univ/1000L), ano_idade)]
setnames(dataset_final2, "trunc", "univ")

dataset <- rbind(dataset_final1, dataset_final2)

dataset[, `:=`(
  idade = substr(ano_idade, 1L, nchar(as.character(ano_idade)) - 5L),
  ano = as.numeric(substr(ano_idade, nchar(as.character(ano_idade)) - 3L, nchar(as.character(ano_idade))))
  )]

#Projeção dapopulação
proj <- as.data.table(read_excel("dados/projecao_pop.xlsx", skip = 3L))
#proj <- proj[!is.na(cod_univ)]
#proj <- proj[, 1L:2L]
#names(proj) <- c("Nome do universo", "Codigo do universo")


proj <- proj[, lapply(.SD, function(x)(as.numeric(x)))]
proj <- proj[!is.na(cod_univ)]
proj[, `Região/Unidade da Federação` := NULL]
proj <- melt(
  data = proj, id.vars = "cod_univ", variable.name = "ano",
  value.name = "pop"
)
setnames(proj, "cod_univ", "univ")
proj[, ano := as.numeric(levels(ano))[ano]]

dataset <- dataset[ano >= 2000L]

dataset <- merge(
  dataset,
  proj,
  all = TRUE,
  by = c("univ", "ano")
)

dataset[, taxa := (obitos/pop)*100000L]
dataset[, univ := as.character(univ)]

#Nível região
#0 a 1 ano
reg_0a1 <- dataset[idade == "0_a_1" & univ %in% c(1L:5L)]
plot_reg_0a1 <- ggplot(reg_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Região Geográfica") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 anos
reg_1a4 <- dataset[idade == "1_a_4" & univ %in% c(1L:5L)]
plot_reg_1a4 <- ggplot(reg_1a4, aes(ano, obitos)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Região Geográfica") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 anos
reg_5a9 <- dataset[idade == "5_a_9" & univ %in% c(1L:5L)]
plot_reg_5a9 <- ggplot(reg_5a9, aes(ano, obitos)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Região Geográfica") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 anos
reg_10a14 <- dataset[idade == "10_a_14" & univ %in% c(1L:5L)]
plot_reg_10a14 <- ggplot(reg_10a14, aes(ano, obitos)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Região Geográfica") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 anos
reg_15a19 <- dataset[idade == "15_a_19" & univ %in% c(1L:5L)]
plot_reg_15a19 <- ggplot(reg_15a19, aes(ano, obitos)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Região Geográfica") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#Nível estados das regiões
#Norte
#0 a 1 ano
nort_0a1 <- dataset[idade == "0_a_1" & univ %in% c(11L:17L)]
plot_nort_0a1 <- ggplot(nort_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Estados do Norte") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 ano
nort_1a4 <- dataset[idade == "1_a_4" & univ %in% c(11L:17L)]
plot_nort_1a4 <- ggplot(nort_1a4, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Estados do Norte") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 ano
nort_5a9 <- dataset[idade == "5_a_9" & univ %in% c(11L:17L)]
plot_nort_5a9 <- ggplot(nort_5a9, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Estados do Norte") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 ano
nort_10a14 <- dataset[idade == "10_a_14" & univ %in% c(11L:17L)]
plot_nort_10a14 <- ggplot(nort_10a14, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Estados do Norte") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 ano
nort_15a19 <- dataset[idade == "15_a_19" & univ %in% c(11L:17L)]
plot_nort_15a19 <- ggplot(nort_15a19, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Estados do Norte") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#Nordeste
#0 a 1 ano
nordest_0a1 <- dataset[idade == "0_a_1" & univ %in% c(21L:29L)]
plot_nordest_0a1 <- ggplot(nordest_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Estados do Nordeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 ano
nordest_1a4 <- dataset[idade == "1_a_4" & univ %in% c(21L:29L)]
plot_nordest_1a4 <- ggplot(nordest_1a4, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Estados do Nordeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 ano
nordest_5a9 <- dataset[idade == "5_a_9" & univ %in% c(21L:29L)]
plot_nordest_5a9 <- ggplot(nordest_5a9, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Estados do Nordeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 ano
nordest_10a14 <- dataset[idade == "10_a_14" & univ %in% c(21L:29L)]
plot_nordest_10a14 <- ggplot(nordest_10a14, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Estados do Nordeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 ano
nordest_15a19 <- dataset[idade == "15_a_19" & univ %in% c(21L:29L)]
plot_nordest_15a19 <- ggplot(nordest_15a19, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Estados do Nordeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#Sudeste
#0 a 1 ano
sudest_0a1 <- dataset[idade == "0_a_1" & univ %in% c(31L:35L)]
plot_sudest_0a1 <- ggplot(sudest_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Estados do Sudeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 ano
sudest_1a4 <- dataset[idade == "1_a_4" & univ %in% c(31L:35L)]
plot_sudest_1a4 <- ggplot(sudest_1a4, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Estados do Sudeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 ano
sudest_5a9 <- dataset[idade == "5_a_9" & univ %in% c(31L:35L)]
plot_sudest_5a9 <- ggplot(sudest_5a9, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Estados do Sudeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 ano
sudest_10a14 <- dataset[idade == "10_a_14" & univ %in% c(31L:35L)]
plot_sudest_10a14 <- ggplot(sudest_10a14, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Estados do Sudeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 ano
sudest_15a19 <- dataset[idade == "15_a_19" & univ %in% c(31L:35L)]
plot_sudest_15a19 <- ggplot(sudest_15a19, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Estados do Sudeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#Sul
#0 a 1 ano
sul_0a1 <- dataset[idade == "0_a_1" & univ %in% c(41L:43L)]
plot_sul_0a1 <- ggplot(sul_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Estados do Sul") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 ano
sul_1a4 <- dataset[idade == "1_a_4" & univ %in% c(41L:43L)]
plot_sul_1a4 <- ggplot(sul_1a4, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Estados do Sul") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 ano
sul_5a9 <- dataset[idade == "5_a_9" & univ %in% c(41L:43L)]
plot_sul_5a9 <- ggplot(sul_5a9, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Estados do Sul") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 ano
sul_10a14 <- dataset[idade == "10_a_14" & univ %in% c(41L:43L)]
plot_sul_10a14 <- ggplot(sul_10a14, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Estados do Sul") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 ano
sul_15a19 <- dataset[idade == "15_a_19" & univ %in% c(41L:43L)]
plot_sul_15a19 <- ggplot(sul_15a19, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Estados do Sul") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#Centro-Oeste
#0 a 1 ano
co_0a1 <- dataset[idade == "0_a_1" & univ %in% c(50L:53L)]
plot_co_0a1 <- ggplot(co_0a1, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças de até 1 ano de idade, por Estados do Centro-Oeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#1 a 4 ano
co_1a4 <- dataset[idade == "1_a_4" & univ %in% c(50L:53L)]
plot_co_1a4 <- ggplot(co_1a4, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 1 e 4 anos de idade, por Estados do Centro-Oeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#5 a 9 ano
co_5a9 <- dataset[idade == "5_a_9" & univ %in% c(50L:53L)]
plot_co_5a9 <- ggplot(co_5a9, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 5 e 9 anos de idade, por Estados do Centro-Oeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#10 a 14 ano
co_10a14 <- dataset[idade == "10_a_14" & univ %in% c(50L:53L)]
plot_co_10a14 <- ggplot(co_10a14, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 10 e 14 anos de idade, por Estados do Centro-Oeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))

#15 a 19 ano
co_15a19 <- dataset[idade == "15_a_19" & univ %in% c(50L:53L)]
plot_co_15a19 <- ggplot(co_15a19, aes(ano, taxa)) +
  geom_line(aes(colour = univ)) +
  ggtitle("Evolução da Taxa de óbitos por Neoplasias Malignas de crianças entre 15 e 19 anos de idade, por Estados do Centro-Oeste") + xlab("Ano") + ylab("Taxa de óbitos - 100 mil hab.") +
  scale_x_continuous(breaks = seq(1996L, 2020L, 1))
