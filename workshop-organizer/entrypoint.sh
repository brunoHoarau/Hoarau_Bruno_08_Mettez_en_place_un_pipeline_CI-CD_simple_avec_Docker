#!/bin/sh
set -e

# Fichier contenant le mot de passe (secret Docker monté par docker compose)
DB_PASSWORD_FILE="${DB_PASSWORD_FILE:-/run/secrets/db_password}"

# Le secret est prioritaire ; sinon on garde SPRING_DATASOURCE_PASSWORD déjà fourni (ex. CI)
if [ -r "$DB_PASSWORD_FILE" ]; then
    SPRING_DATASOURCE_PASSWORD="$(tr -d '\r\n' < "$DB_PASSWORD_FILE")"
    export SPRING_DATASOURCE_PASSWORD
elif [ -z "${SPRING_DATASOURCE_PASSWORD:-}" ]; then
    echo "Erreur : ni secret $DB_PASSWORD_FILE ni variable SPRING_DATASOURCE_PASSWORD" >&2
    exit 1
fi

exec java -jar app.war "$@"
