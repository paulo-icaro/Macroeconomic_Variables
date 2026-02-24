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
library(lubridate)



# ================================ #
# === 2. Macroeconomic Dataset === #
# ================================ #
source('https://raw.githubusercontent.com/paulo-icaro/Macroeconomic_Variables/refs/heads/master/API_Dataset.R')



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
#* @apiTag "Séries Macroeconômicas Mensais" Acesso as séries macroeconômicas mensais



# ---------------------- #
# --- 3.2 Minor Tags --- #
# ---------------------- #

# --- 3.2.1 Tag - Monthly Series --- #
# Warnings:
# - @get: It's a method defined by the Endpoint. In this case the get method is chosen
# - @serializer: Defines how Plumber returns results to the client (default JSON)

#* @get /macro_series_mensais
#* @serializer json       
#* @tag "Séries Macroeconômicas Mensais"
#* @param series Informe o código da(s) série(s) de dados desejada(s)
#* @param periodo Intervalo de dados (Ex: 2010-2020)

function(series = 'tudo', periodo = 'tudo'){
  
  # --- Default --- #
  macroeconomic_dataset = monthly_macro_series
  
  
  # --- Filtering Series --- #
  if(series != 'tudo'){
    
    # This line avoids unecessary computing each time the filter is activated
    series_vec = unlist(strsplit(series, ","))
    
    # Database
    macroeconomic_dataset = 
      macroeconomic_dataset %>%
      select(data, all_of(series_vec))
  }
 
 
  # --- Filtering Period --- #
  if(periodo != 'tudo'){
    
    # These lines avoid unecessary computing each time the filter is activated
    initial_period = as.numeric(substr(periodo, 1, 4))    
    final_period = as.numeric(substr(periodo, 6, 9))
    start_date = as.Date(paste0(initial_period, '-01-01'))
    end_date = as.Date(paste0(final_period, '-12-31'))
    
    # Database
    macroeconomic_dataset =
      macroeconomic_dataset %>%
      filter(data >= start_date, data <= end_date)
  }
  
  return(macroeconomic_dataset)
}


# --- 3.2.2 Tag - Quartely Series --- #
#* @get /macro_series_trimestrais
#* @serializer json       
#* @tag "Séries Macroeconômicas Trimestrais"
#* @param series Informe o código da(s) série(s) de dados desejada(s)
#* @param periodo Intervalo de dados (Ex: 2015-2025)

function(series = 'tudo', periodo = 'tudo'){
  
  # --- Default --- #
  macroeconomic_dataset = quartely_macro_series
  
  
  # --- Filtering Series --- #
  if(series != 'tudo'){
    
    # This line avoids unecessary computing each time the filter is activated
    series_vec = unlist(strsplit(series, ","))
    
    # Database
    macroeconomic_dataset = 
      macroeconomic_dataset %>%
      select(data, all_of(series_vec))
  }
  
  
  # --- Filtering Period --- #
  if(periodo != 'tudo'){
    
    # These lines avoid unecessary computing each time the filter is activated
    initial_period = as.numeric(substr(periodo, 1, 4))    
    final_period = as.numeric(substr(periodo, 6, 9))
    start_date = as.Date(paste0(initial_period, '-01-01'))
    end_date = as.Date(paste0(final_period, '-12-31'))
    
    # Database
    macroeconomic_dataset =
      macroeconomic_dataset %>%
      filter(data >= start_date, data <= end_date)
  }
  
  return(macroeconomic_dataset)
}


# Run this in case you want run the API
# pr(file = paste0(getwd(), '/API_Structure.R')) %>% pr_run()