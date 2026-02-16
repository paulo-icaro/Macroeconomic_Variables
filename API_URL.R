# ========================================= #
# === MACROECONOMIC VARIABLES - API URL === #
# ========================================= #

# --- Script by Paulo Icaro --- #

# --------------------------------- #
# --- URL's Generation Function --- #
# --------------------------------- #
macroeconomic_variables_url = function(variable, start, end, frequency){
  base_url = 
}


bacen_url = function(serie, data_inicio, data_termino){
  url = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs.'
  
  for(i in serie){
    bacen_url = paste0(url, serie, '/dados?formato=json&dataInicial=', data_inicio, '&dataFinal=', data_termino)
  }
  
  return(bacen_url)
}