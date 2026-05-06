#!/bin/bash
# init-db.sh — cria os bancos listmonk e outline automaticamente
# Coloque em ./init-db.sh (mesma pasta do docker-compose.yml)

set -e

function create_db() {
  local db=$1
  echo "Criando banco: $db"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    SELECT 'CREATE DATABASE $db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
    GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
EOSQL
}

create_db listmonk
create_db outline
