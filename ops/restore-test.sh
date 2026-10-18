#!/usr/bin/env bash
# Test de restauration : restaure la dernière sauvegarde dans un environnement jetable
# (PostgreSQL + API), vérifie le contenu, puis supprime tout. La production n'est pas touchée.
# À lancer depuis le dossier workshop-organizer/.
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/workshop-organizer}"
DB_CONTAINER="${DB_CONTAINER:-workshop-db}"
APP_IMAGE="${APP_IMAGE:-workshop-organizer:latest}"
set -a; . ./.env; set +a

dump="$(ls -t "$BACKUP_DIR"/workshopsdb-*.dump | head -1)"
(cd "$BACKUP_DIR" && sha256sum -c --quiet "$(basename "$dump").sha256")

export RT_PASSWORD="$(openssl rand -hex 16)"
cleanup() { docker rm -f rt-db rt-app >/dev/null 2>&1; docker network rm rt-net >/dev/null 2>&1; }
trap cleanup EXIT
docker network create rt-net >/dev/null
docker run -d --name rt-db --network rt-net -e POSTGRES_DB=rt -e POSTGRES_PASSWORD="$RT_PASSWORD" postgres:13 >/dev/null
until docker exec rt-db pg_isready -q -h 127.0.0.1 -U postgres -d rt; do sleep 2; done

start=$(date +%s)
docker exec -i rt-db pg_restore -U postgres -d rt --no-owner --exit-on-error < "$dump"
docker run -d --name rt-app --network rt-net -e SPRING_DATASOURCE_URL=jdbc:postgresql://rt-db:5432/rt \
  -e SPRING_DATASOURCE_USERNAME=postgres -e SPRING_DATASOURCE_PASSWORD="$RT_PASSWORD" "$APP_IMAGE" >/dev/null
until docker exec rt-app curl -fsS -o /dev/null http://127.0.0.1:8080/api/workshops 2>/dev/null; do
  (( $(date +%s) - start > 180 )) && { echo "ECHEC : l'API ne répond pas"; docker logs --tail 20 rt-app; exit 1; }
  sleep 3
done
rto=$(( $(date +%s) - start ))

sql="select (select count(*) from notion_model)||' notions, '||(select count(*) from workshop_model)||' ateliers, '||(select count(*) from workshop_model_notions)||' liens'"
restored="$(docker exec rt-db psql -U postgres -d rt -tAc "$sql")"
prod="$(docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "$sql")"
api="$(docker exec rt-app curl -fsS http://127.0.0.1:8080/api/workshops | head -c 120)"

echo "Sauvegarde testée : $(basename "$dump")"
echo "Restaurée        : $restored"
echo "Production       : $prod"
echo "API restaurée    : $api"
echo "Durée (restauration + démarrage API) : ${rto} s"
echo "RESULTAT : SUCCES"
