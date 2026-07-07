################################################################################
#
#                                SÉRIES TEMPORAIS 
#
################################################################################
rm(list=ls())

library(GetBCBData) 
library(ipeadatar) 
library(dplyr)  
library(stringr)
library(lubridate)
library(writexl)

################################################################################
#                   Extração dos dados - IPEA/SGS
################################################################################

#PIB Nominal - Mensal - Milhões
pib <- ipeadata("BM12_PIB12")

#Consumo das Famílias - Trimestral  - Milhões 
cons_fam <- ipeadata("SCN104_CFPPN104")

#Consumo do Governo - Trimestral  - Milhões
cons_gov <- ipeadata("SCN104_CFGGN104")

#Formação bruta de capital fixo - trimestral - R$ (milhões)
inv <- ipeadata("SCN104_FBKFN104")

#Valor FOB das exportações: total geral - Mensal - US$ (milhões)
export <- ipeadata("FUNCEX12_XVT12")

#Valor FOB das importações: total geral - Mensal - US$ (milhões)
import <- ipeadata("SECEX12_MVTOT12")

#	Taxa de câmbio - R$ / US$ - comercial - venda - média - mensal 
tx_camb <- ipeadata("BM12_ERV12")

#IPCA - Mensal 
ipca <- ipeadata("PRECOS12_IPCA12")

#Taxa de juros nominal - Overnight / Selic - mensal 
selic <- ipeadata("PAN12_TJOVER12")

#Utilização da capacidade instalada - indústria -  (média 2006 = 100) - (%) - Mensal 
uci <- gbcbd_get_series(
  id = c("UCI" = 28561),
  first.date = "2001-12-01",
  last.date = Sys.Date()  
)

#Superávit primário do governo consolidado - R$ (milhões) - Mensal
sp_p <- gbcbd_get_series(
  id = c("Resultado primário" = 4649),
  first.date = "2001-12-01",
  last.date = Sys.Date()  
)

################################################################################
#                   Ajuste de Frequência - Trimestral
################################################################################

#PIB - Trimestral - 1T2022 - 4T2024
pib_tr <- pib %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(pib_nominal = sum(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#Consumo das Famílias - Trimestral - 1T2022 - 4T2024
cons_fam_tr <- cons_fam %>%
  mutate(
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  select(Ano, Trimestre, cons_fam = value) %>%  
  filter(Ano >= 2002, Ano <= 2024) %>%
  arrange(Ano, Trimestre)


#Consumo do Governo - Trimestral - 1T2022 - 4T2024
cons_gov_tr <- cons_gov %>%
  mutate(
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  select(Ano, Trimestre, cons_gov = value) %>%  
  filter(Ano >= 2002, Ano <= 2024) %>%
  arrange(Ano, Trimestre)


#FBCF - Trimestral - 1T2022 - 4T2024
inv_tr <- inv %>%
  mutate(
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  select(Ano, Trimestre, invest = value) %>%  
  filter(Ano >= 2002, Ano <= 2024) %>%
  arrange(Ano, Trimestre)


#Exportações - Trimestral - 1T2022 - 4T2024
export_tr <- export %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(exportacao = sum(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#Importações - Trimestral - 1T2022 - 4T2024
import_tr <- import %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(importacao = sum(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#Taxa de Câmbio - Trimestral - 1T2022 - 4T2024
tx_camb_tr <- tx_camb %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(tx_cambio = mean(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#IPCA - Trimestral - 1T2022 - 4T2024 (método 1)
ipca_tr <- ipca %>%
  mutate(
    date = as.Date(date),
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  # Defina aqui o seu período de análise
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(ipca_indice = mean(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre) %>%
  mutate(
    ipca_variacao = (ipca_indice / lag(ipca_indice)) - 1,
    ipca_variacao_pp = ipca_variacao * 100
  )


#IPCA - Trimestral - 1T2022 - 4T2024 (Método 2)
ipca_tr_2 <- ipca %>%
  mutate(
    date = as.Date(date),
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%
  arrange(date) %>%
  group_by(Ano, Trimestre) %>%
  summarise(
    ipca_indice_2 = last(value), 
    .groups = "drop"
  ) %>%
  arrange(Ano, Trimestre) %>%
  mutate(
    ipca_variacao = (ipca_indice_2 / lag(ipca_indice_2)) - 1,
    ipca_variacao_pp = ipca_variacao * 100
  )


#SELIC - Trimestral - 1T2022 - 4T2024 (método 1)
selic_tr <- selic %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(selic = mean(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#SELIC - Trimestral - 1T2022 - 4T2024 (método 2)
selic_tr_2 <- selic %>%
  mutate(
    date = as.Date(date),                      
    Ano = year(date),
    Trimestre = quarter(date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(selic_2 = last(value), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#Utilização da capacidade instalada - Trimestral - 1T2022 - 4T2024
uci_tr <- uci %>% 
  mutate(
    date = as.Date(ref.date),                      
    Ano = year(ref.date),
    Trimestre = quarter(ref.date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(uci = mean(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


#Superávit primário - Trimestral - 1T2022 - 4T2024
sp_tr <- sp_p %>%
  mutate(
    date = as.Date(ref.date),                      
    Ano = year(ref.date),
    Trimestre = quarter(ref.date)
  ) %>%
  filter(Ano > 2001, Ano < 2025) %>%            
  group_by(Ano, Trimestre) %>%
  summarise(Result_Prim = sum(value, na.rm = TRUE), .groups = "drop") %>%
  arrange(Ano, Trimestre)


###############################################################################
#                         Ajuste de câmbio - Exp/Imp-  US$ => R$
##############################################################################
exterior <- export_tr %>%
  full_join(import_tr, by = c("Ano", "Trimestre")) %>%
  full_join(tx_camb_tr, by = c("Ano", "Trimestre")) %>%
  mutate(
    # Convertendo para Reais (R$ Milhões)
    exportacao_br = exportacao * tx_cambio,
    importacao_br = importacao * tx_cambio
  )


################################################################################
#                      Gráficos das séries 
################################################################################

#Transformar as séries em objetos do tipo ts
pib_ts <- ts(pib_tr$pib_nominal, start = c(2002,1), end = c(2024,4), frequency = 4)
cons_fam_ts <- ts(cons_fam_tr$cons_fam, start = c(2002,1), end = c(2024,4), frequency = 4)
cons_gov_ts <- ts(cons_gov_tr$cons_gov, start = c(2002,1), end = c(2024,4), frequency = 4)
inv_ts <- ts(inv_tr$invest, start = c(2002,1), end = c(2024,4), frequency = 4)
export_ts <- ts(exterior$exportacao_br, start = c(2002,1), end = c(2024,4), frequency = 4)
import_ts <- ts(exterior$importacao_br, start = c(2002,1), end = c(2024,4), frequency = 4)
tx_camb_ts <- ts(tx_camb_tr$tx_cambio, start = c(2002,1), end = c(2024,4), frequency = 4)
ipca_ts <- ts(ipca_tr$ipca_indice, start = c(2002,1), end = c(2024,4), frequency = 4)
ipca_vr_ts <- ts(ipca_tr$ipca_variacao_pp, start = c(2002,1), end = c(2024,4), frequency = 4)
ipca_2_ts <- ts(ipca_tr_2$ipca_indice_2, start = c(2002,1), end = c(2024,4), frequency = 4)
selic_ts <- ts(selic_tr$selic, start = c(2002,1), end = c(2024,4), frequency = 4)
selic_2_ts <- ts(selic_tr_2$selic_2, start = c(2002,1), end = c(2024,4), frequency = 4)
uci_ts <- ts(uci_tr$uci, start = c(2002,1), end = c(2024,4), frequency = 4)
sp_ts <- ts(sp_tr$Result_Prim, start = c(2002,1), end = c(2024,4), frequency = 4)


#Comparação das séries que foram transformadas com 02 métodos
par(mfrow = c(1, 1))

#IPCA
plot(ipca_ts, main = "IPCA", xlab ="", ylab ="índice", type = "l", col = "blue")
lines(ipca_2_ts, col = "red")
legend("topleft", legend = c("Método 1", "Método 2"),  
       col = c("blue", "red"), lty = 1, lwd = 2, bty = "n",  cex = 0.6) 

#SELIC
plot(selic_ts, main = "SELIC", xlab ="", ylab ="%", type = "l", col = "blue")
lines(selic_2_ts, col = "red")
legend("topright", legend = c("Método 1", "Método 2"),  
       col = c("blue", "red"), lty = 1, lwd = 2, bty = "n",  cex = 0.6) 

#Todos os gráficos 
par(mfrow = c(2, 2))

plot(pib_ts/1000, main = "PIB", xlab ="", ylab ="R$", type = "l", col = "red")
plot(cons_fam_ts/1000, main = "Consumo das Famílias", xlab ="", ylab ="R$", type = "l", col = "blue")
plot(cons_gov_ts/1000, main = "Consumo do Governo", xlab ="", ylab ="R$", type = "l", col = "darkgreen")
plot(inv_ts/1000, main = "Investimento (FBCF)", xlab ="", ylab ="R$", type = "l", col = "black")
plot(export_ts/1000, main = "FOB: Exportações", xlab ="", ylab ="R$", type = "l", col = "purple")
plot(import_ts/1000, main = "FOB: Importações", xlab ="", ylab ="R$", type = "l", col = "darkred")
plot(tx_camb_ts, main = "Taxa de Câmbio", xlab ="", ylab ="%", type = "l", col = "orange")
plot(ipca_ts, main = "IPCA", xlab ="", ylab ="índice", type = "l", col = "brown")
plot(ipca_vr_ts, main = "IPCA - var(%)", xlab ="", ylab ="%", type = "l", col = "salmon")
plot(selic_ts, main = "SELIC", xlab ="", ylab ="%", type = "l", col = "green")
plot(uci_ts, main = "Utilização da Capacidade Instalada", xlab ="", ylab ="%", type = "l", col = "cyan")
plot(sp_ts/1000, main = "Resultado Primário ", xlab ="", ylab ="R$", type = "l", col = "magenta")


par(mfrow = c(1, 1))


################################################################################
#                           AJUSTE SAZONAL 
################################################################################
library(tidyverse)
library(seasonal)

par(mfrow = c(2, 2))

#PIB 
pib_aj <- seas(pib_ts)
plot(pib_aj, main = "PIB: Série Original e Ajustada", xlab="")

#Consumo das famílias 
cons_fam_aj <- seas(cons_fam_ts)
plot(cons_fam_aj, main = "Consumo das famílias: Série Original e Ajustada", xlab="")

#Consumo do governo 
cons_gov_aj <- seas(cons_gov_ts)
plot(cons_gov_aj, main = "Consumo do governo: Série Original e Ajustada", xlab="")

#Investimento
inv_aj <- seas(inv_ts)
plot(inv_aj, main = "FBCF: Série Original e Ajustada", xlab="")

#Exportação
export_aj <- seas(export_ts)
plot(export_aj, main = "Exportações: Série Original e Ajustada", xlab="")

#Importação
import_aj <- seas(import_ts)
plot(import_aj, main = "Importações: Série Original e Ajustada", xlab="")

#Taxa de câmbio
tx_camb_aj <- seas(tx_camb_ts)
plot(tx_camb_aj, main = "Taxa de Câmbio: Série Original e Ajustada", xlab="")

#IPCA
ipca_aj <- seas(ipca_ts)
plot(ipca_aj, main = "IPCA: Série Original e Ajustada", xlab="")

#IPCA - var(%)
ipca_var_aj <- seas(ipca_vr_ts)
plot(ipca_var_aj, main = "IPCA - var(%): Série Original e Ajustada", xlab="")

#selic
selic_aj <- seas(selic_ts)
plot(selic_aj, main = "Selic: Série Original e Ajustada", xlab="")

#Superávit primário
sp_aj <- seas(sp_ts)
plot(sp_aj, main = "Resultado primário: Série Original e Ajustada", xlab="")

par(mfrow = c(1, 1))

#Retira os valores ajustados 
pib_final <- final(pib_aj)
cons_fam_final <- final(cons_fam_aj)
cons_gov_final <- final(cons_gov_aj)
inv_final <- final(inv_aj)
export_final <- final(export_aj)
import_final <- final(import_aj)
tx_camb_final <- tx_camb_ts
ipca_final <-  ipca_ts
ipca_vr_final <- ipca_vr_ts
selic_final <- selic_ts  
uci_final <- uci_ts
sp_final <- final(sp_aj)

#Retornar ao formato anterior (tibbes)

# Carregando pacotes necessários
library(dplyr)
library(tibble)
library(purrr)

# Criar a sequência de trimestres de 2002T1 até 2024T4
trimestres <- expand.grid(
  Trimestre = 1:4,
  Ano = 2002:2024
) %>%
  arrange(Ano, Trimestre)

# Transformar cada vetor ajustado em tibble no mesmo padrão das séries originais
pib_df <- trimestres %>% mutate(pib_nominal = as.numeric(pib_final))
cons_fam_df <- trimestres %>% mutate(cons_fam = as.numeric(cons_fam_final))
cons_gov_df <- trimestres %>% mutate(cons_gov = as.numeric(cons_gov_final))
inv_df <- trimestres %>% mutate(invest = as.numeric(inv_final))
export_df <- trimestres %>% mutate(exportacao = as.numeric(export_final))
import_df <- trimestres %>% mutate(importacao = as.numeric(import_final))
sp_df <- trimestres %>% mutate(Result_Prim = as.numeric(sp_final))

# Séries que não foram ajustadas sazonalmente (mantidas como estavam)
tx_camb_df <- trimestres %>% mutate(tx_cambio = as.numeric(tx_camb_final))
ipca_df <- trimestres %>% mutate(ipca_indice = as.numeric(ipca_final))
ipca_vr_df <- trimestres %>% mutate(ipca_var = as.numeric(ipca_vr_final))
selic_df <- trimestres %>% mutate(selic = as.numeric(selic_final))
uci_df <- trimestres %>% mutate(uci = as.numeric(uci_final))

#Agregação das séries em um único dataframe
dados <- list(
  pib_df,
  cons_fam_df,
  cons_gov_df,
  inv_df,
  export_df,
  import_df,
  tx_camb_df,
  ipca_df,
  ipca_vr_df,
  selic_df,
  uci_df,
  sp_df
) %>%
  reduce(full_join, by = c("Ano", "Trimestre")) %>%
  arrange(Ano, Trimestre)


#Criação de novas variáveis 
dados <- dados %>% 
  mutate(
    y = log(pib_nominal),
    pi_c = ipca_indice,
    pi_v = ipca_var,
    r = selic, 
    i = (invest / pib_nominal)*100,
    ex = (exportacao / pib_nominal)*100,
    im = (importacao / pib_nominal)*100,
    c = (cons_fam / pib_nominal)*100,
    g = (cons_gov / pib_nominal)*100,
    u = uci,
    u_norm = (uci - min(uci, na.rm = TRUE)) / (max(uci, na.rm = TRUE) - min(uci, na.rm = TRUE)),
    s = tx_cambio,
    sp = (Result_Prim / pib_nominal)*100
    
  )



################################################################################
#             TESTES DE ESTACIONARIEDADE
################################################################################

library(urca)
library(dplyr)
library(knitr) 

# Lista das variáveis
variaveis_para_testar <- c("y", "pi_c", "pi_v", "r", "i", "ex", "im", "c", "g", "u", "s", "sp")

# 1. TESTE DE DICKEY-FULLER AUMENTADO (ADF)
# H0: A série possui raiz unitária (não é estacionária).
# Se a estatística do teste for MENOR que o valor crítico, rejeitamos H0.

resultados_adf <- list()

for (variavel in variaveis_para_testar) {
  # Extrai a série temporal, tratando possíveis valores NA
  serie_ts <- ts(dados[[variavel]], start = c(2002, 1), frequency = 4)
  
  # Realiza o teste ADF com o modelo mais geral (com drift e tendência)
  # selectlags = "AIC" escolhe o número de defasagens automaticamente
  teste_adf <- ur.df(na.omit(serie_ts), type = "trend", selectlags = "AIC")
  
  # Armazena o resultado
  resultados_adf[[variavel]] <- teste_adf
}

# 2. TESTE KPSS (Kwiatkowski-Phillips-Schmidt-Shin)
# H0: A série é estacionária.
# Se a estatística do teste for MAIOR que o valor crítico, rejeitamos H0.

resultados_kpss <- list()

for (variavel in variaveis_para_testar) {
  # Extrai a série temporal
  serie_ts <- ts(dados[[variavel]], start = c(2002, 1), frequency = 4)
  
  # Realiza o teste KPSS para testar estacionariedade em torno de uma tendência
  teste_kpss <- ur.kpss(na.omit(serie_ts), type = "tau", use.lag = 4)
  
  # Armazena o resultado
  resultados_kpss[[variavel]] <- teste_kpss
}


################################################################################
#           Exibição e Interpretação dos Resultados
################################################################################

# Criar uma tabela-resumo para facilitar a visualização

# Extrair os valores importantes do teste ADF
sumario_adf <- t(sapply(resultados_adf, function(teste) {
  estatistica <- teste@teststat[1]
  crit_1_porcento <- teste@cval[1, 1]
  crit_5_porcento <- teste@cval[1, 2]
  crit_10_porcento <- teste@cval[1, 3]
  resultado_5_porcento <- ifelse(estatistica < crit_5_porcento, "Estacionária", "Não Estacionária")
  return(c(Estatistica = round(estatistica, 3), 
           `Valor Crítico 5%` = crit_5_porcento, 
           `Resultado (5%)` = resultado_5_porcento))
}))

# Extrair os valores importantes do teste KPSS
sumario_kpss <- t(sapply(resultados_kpss, function(teste) {
  estatistica <- teste@teststat[1]
  crit_1_porcento <- teste@cval[1, 1]
  crit_5_porcento <- teste@cval[1, 2]
  crit_10_porcento <- teste@cval[1, 3]
  resultado_5_porcento <- ifelse(estatistica > crit_5_porcento, "Não Estacionária", "Estacionária")
  return(c(Estatistica = round(estatistica, 3), 
           `Valor Crítico 5%` = crit_5_porcento, 
           `Resultado (5%)` = resultado_5_porcento))
}))

# Combinar os resultados em uma única tabela
df_adf <- as.data.frame(sumario_adf)
colnames(df_adf) <- c("ADF_Estatistica", "ADF_Critico_5%", "ADF_Resultado")

df_kpss <- as.data.frame(sumario_kpss)
colnames(df_kpss) <- c("KPSS_Estatistica", "KPSS_Critico_5%", "KPSS_Resultado")

tabela_final_testes <- cbind(Variavel = rownames(df_adf), df_adf, df_kpss)
rownames(tabela_final_testes) <- NULL

# Exibir a tabela formatada com kable
kable(tabela_final_testes, caption = "Resultados dos Testes de Estacionariedade (Nível)")


################################################################################
#                      Primeira Diferença 
################################################################################

# 1. Identificar variáveis NÃO estacionárias (segundo ADF E KPSS)
variaveis_nao_estacionarias <- rownames(df_adf)[
  df_adf$ADF_Resultado == "Não Estacionária" & df_kpss$KPSS_Resultado == "Não Estacionária"
]

# 2. Calcular a primeira diferença dessas variáveis 

dados_diff <- dados %>%
  mutate(across(
    all_of(variaveis_nao_estacionarias),
    ~ . - lag(.),
    .names = "{.col}_diff"
  ))


# Seleciona nomes das variáveis com "_diff"
variaveis_diferenciadas <- names(dados_diff)[grepl("_diff$", names(dados_diff))]

# ADF
resultados_adf_diff <- list()

for (variavel in variaveis_diferenciadas) {
  serie_ts <- ts(dados_diff[[variavel]], start = c(2002, 1), frequency = 4)
  teste_adf <- ur.df(na.omit(serie_ts), type = "trend", selectlags = "AIC")
  resultados_adf_diff[[variavel]] <- teste_adf
}

# KPSS
resultados_kpss_diff <- list()

for (variavel in variaveis_diferenciadas) {
  serie_ts <- ts(dados_diff[[variavel]], start = c(2002, 1), frequency = 4)
  teste_kpss <- ur.kpss(na.omit(serie_ts), type = "tau", use.lag = 4)
  resultados_kpss_diff[[variavel]] <- teste_kpss
}


# ADF
sumario_adf_diff <- t(sapply(resultados_adf_diff, function(teste) {
  estatistica <- teste@teststat[1]
  crit_5_porcento <- teste@cval[1, 2]
  resultado <- ifelse(estatistica < crit_5_porcento, "Estacionária", "Não Estacionária")
  c(Estatistica = round(estatistica, 3),
    `Valor Crítico 5%` = crit_5_porcento,
    `Resultado (5%)` = resultado)
}))

# KPSS
sumario_kpss_diff <- t(sapply(resultados_kpss_diff, function(teste) {
  estatistica <- teste@teststat[1]
  crit_5_porcento <- teste@cval[1, 2]
  resultado <- ifelse(estatistica > crit_5_porcento, "Não Estacionária", "Estacionária")
  c(Estatistica = round(estatistica, 3),
    `Valor Crítico 5%` = crit_5_porcento,
    `Resultado (5%)` = resultado)
}))

# Combinar os resultados
df_adf_diff <- as.data.frame(sumario_adf_diff)
colnames(df_adf_diff) <- c("ADF_Estatistica", "ADF_Critico_5%", "ADF_Resultado")

df_kpss_diff <- as.data.frame(sumario_kpss_diff)
colnames(df_kpss_diff) <- c("KPSS_Estatistica", "KPSS_Critico_5%", "KPSS_Resultado")

tabela_final_diff <- cbind(Variavel = rownames(df_adf_diff), df_adf_diff, df_kpss_diff)
rownames(tabela_final_diff) <- NULL


kable(tabela_final_diff, caption = "Resultados dos Testes de Estacionariedade (1ª Diferença)")


