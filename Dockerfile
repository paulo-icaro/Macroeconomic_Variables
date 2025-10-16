# 1. Imagem base com R
FROM rocker/r-ver:4.3.1

# 2. Variáveis de ambiente (não abre portas, só evita prompts)
ENV DEBIAN_FRONTEND=noninteractive

# 3. Dependências do sistema necessárias para compilar/rodar pacotes R
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    make \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Criar diretório de trabalho
WORKDIR /app

# 5. Instalar pacotes R necessários (útil manter em uma linha para cache)
#RUN R -e "install.packages(c('plumber','tidyverse','readxl'), repos='https://cloud.r-project.org')"

# 5. Instalar pacotes R (via script install2.r do rocker)
RUN install2.r --error \
    plumber \
    dplyr \
    readxl

# 6. Copiar o projeto para dentro do container
COPY . /app

# 7. Expor a porta (informativa)
EXPOSE 8000

# 8. Comando que inicia o plumber
CMD ["Rscript", "-e", "library(dplyr); library(plumber); pr(file = 'API_Structure.R') %>% pr_run(host = '0.0.0.0', port = 8000)"]