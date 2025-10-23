# ============================================= #
# === MACROECONOMIC VARIABLES - API DATASET === #
# ============================================= #

# --- Script by Paulo Icaro --- #

# Plumber Website: https://www.rplumber.io/
# Tutoriais:
# i - https://icaroagostino.github.io/post/plumber/
# ii - https://www.appsilon.com/post/r-rest-api
# iii - https://posit.co/blog/creating-apis-for-data-science-with-plumber/



# ==================== #
# === 1. Libraries === #
# ==================== #

# ------------------------------ #
# --- 1.1 Auxiliary Packages --- #
# ------------------------------ #
#source('https://raw.githubusercontent.com/paulo-icaro/Package_Requestor/refs/heads/main/Package_Requestor.R')

# --------------------- #
# --- 1.2 Libraries --- #
# --------------------- #
#package_requestor(c('plumber', 'dplyr', 'readxl'))   # Run only if the packages are not installed
library(plumber)
library(dplyr)
library(readxl)



# ================================ #
# === 2. Macroeconomic Dataset === #
# ================================ #
macroeconomic_dataset = 
  read_excel(path = 'Dataset/Dataset.xlsx',
             sheet = 'Data',
             range = cell_cols('A:AK'),
             col_names = TRUE)



# ============== #
# === 3. API === #
# ============== #

#* @apiTitle Conjunto de Dados Macroeconômicos
#* @apiDescription A proposta desse API é disponibilizar um conjunto de dados macroeconômicos voltados para fins de pesquisa. Tais informações são de caráter público e podem facilmente ser acessadas principalmente através das principais plataformas de dados economicos nacional: <br> <li>[Banco Central do Brasil (SGS Bacen) ](https://www3.bcb.gov.br/sgspub/localizarseries/localizarSeries.do?method=prepararTelaLocalizarSeries)</li><li>[Instituto IPEA (IPEADATA)](https://www.ipeadata.gov.br/Default.aspx)</li><li>[IBGE (SIDRA)](https://sidra.ibge.gov.br/home/pimpfbr/brasil)</li>
#* @apiVersion 1.0.0



# ---------------------- #
# --- 3.1 Major Tags --- #
# ---------------------- #
# Warnings:
# i) Don't forget to associate each @apiTag element with its respective @tag element, unless you want the default name
#* @apiTag "Índice de Preços ao Consumidor Amplo (IPCA)" Acesso a série do Índice de Preços ao Consumidor Amplo




# ---------------------- #
# --- 3.2 Minor Tags --- #
# ---------------------- #

# --- 3.2.1 Tag - Price Index --- #
# Warnings:
# - @get: It's a method define by the Endpoint. In this case the get method is chosen
# - @serializer: Defines how Plumber returns results to the client (default JSON)

#* @get /ipca
#* @serializer json       
#* @tag "Índice de Preços ao Consumidor Amplo (IPCA)"
#* @param serie Informe o código da série de dados desejada
#* @param frequencia Frequência desejada (Ex: Anual, Mensal, Bimestral, ...)
#* @param periodo Intervalo de dados (Ex: 2010-2020, 2010M01-2020M06, 2010B01-2020B03, ...)

function(serie, frequencia, periodo){
  macroeconomic_dataset
}


# Run this in case you want run the API
# pr(file = paste0(getwd(), '/API_Structure.R')) %>% pr_run()