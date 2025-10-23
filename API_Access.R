# ============================================ #
# === MACROECONOMIC VARIABLES - API ACCESS === #
# ============================================ #

# --- Script by Paulo Icaro --- #

# ==================== #
# === 1. Libraries === #
# ==================== #

# ------------------------------ #
# --- 1.1 Auxiliary Packages --- #
# ------------------------------ #
source('https://raw.githubusercontent.com/paulo-icaro/Package_Requestor/refs/heads/main/Package_Requestor.R')

# --------------------- #
# --- 1.2 Libraries --- #
# --------------------- #
#package_requestor(c('httr2', 'jsonlite', 'dplyr'))   # Run only if the packages are not installed
library(httr2)				                                # Connects to the API Server
library(jsonlite)			                                # Converts Json data to an object
library(dplyr)				                                # Helps to manipulate data



# =================================== #
# === 2. Data Collection Function === #
# =================================== #
macroeconomic_dataset = function(url, show_flags = TRUE, show_first_10 = TRUE){
	message('Iniciando a conexão com a API')
	Sys.sleep(1)

	# -------------------------- #
	# --- 2.1 API Connection --- #
	# -------------------------- #
	api_connection = try(expr = request(base_url = url) %>% req_perform(), silent = TRUE)
	attempts = 1
	
	if(class(api_connection) == 'try-error'){
		while(class(api_connection) == 'try-error' & attempts <= 5){
			if(show_flags == TRUE){
				message('Problemas na conexão. Tentando acessar a API novamente ...\n')
				Sys.sleep(1)
			}
			api_connection = try(expr = request(base_url = url) %>% req_perform(), silent = TRUE)
			attempts = attempts + 1
			if(attempts > 5){message('Conexão mal sucedida ! \nTente conectar com a API mais tarde.')}
		}
	} else {
		if(attempts <= 2){message('Conexão bem sucedida !')} else {message(paste0('Conexão bem sucedida após ', attempts, ' tentativas.'))}
		Sys.sleep(1)
	}

	api_connection = rawToChar(api_connection$body)
	api_connection = fromJSON(api_connection, flatten = TRUE)

	# -------------------------- #
	# --- 2.2 Show some data --- #
	# -------------------------- #
	if(show_first_10 == TRUE){head(api_connection, 10)}
	
}