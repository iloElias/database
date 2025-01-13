#!/bin/bash

set -e

BASE_DIR=$(dirname "$(readlink -f "$0")")

SCRIPT_DIR="$BASE_DIR/database/scripts"

DOCKER_COMPOSE_FILE="$BASE_DIR/database/docker/docker-compose.yml"
SYSTEMD_SERVICE_FILE="$SCRIPT_DIR/mapdata-global-databases.service"
START_SCRIPT_FILE="$SCRIPT_DIR/start-mapdata-global-databases.sh"

GLOBAL_NETWORK="mapdata-network"

create_global_network() {
  echo "Verificando se a rede global '$GLOBAL_NETWORK' existe..."
  if ! docker network ls | grep -q "$GLOBAL_NETWORK"; then
    echo "Criando a rede global '$GLOBAL_NETWORK'..."
    docker network create "$GLOBAL_NETWORK"
  else
    echo "Rede global '$GLOBAL_NETWORK' já existe."
  fi
}

setup_permissions() {
  echo "Configurando permissões para os scripts..."
  chmod +x "$START_SCRIPT_FILE"
}

setup_systemd_service() {
  echo "Configurando o serviço systemd para iniciar os bancos de dados globais..."
  sudo cp "$SYSTEMD_SERVICE_FILE" /etc/systemd/system/mapdata-global-databases.service
  sudo systemctl daemon-reload
  sudo systemctl enable mapdata-global-databases.service
}

start_docker_services() {
  echo "Inicializando os serviços do Docker Compose..."
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d
}

run_start_script() {
  echo "Executando o script de inicialização..."
  sudo "$START_SCRIPT_FILE"
}

echo "Iniciando o setup completo do ambiente..."
create_global_network
setup_permissions
setup_systemd_service
start_docker_services
run_start_script
echo "Setup completo!"