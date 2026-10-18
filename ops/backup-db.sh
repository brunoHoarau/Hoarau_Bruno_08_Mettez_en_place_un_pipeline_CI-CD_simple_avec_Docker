#!/usr/bin/env bash
# Sauvegarde logique de la base Workshop Organizer (pg_dump, format custom compressé).
# À lancer depuis le dossier workshop-organizer/ (lit POSTGRES_DB et POSTGRES_USER dans .env).
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/workshop-organizer}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DB_CONTAINER="${DB_CONTAINER:-workshop-db}"

set -a; . ./.env; set +a
ts="$(date +%Y%m%d-%H%M%S)"
file="$BACKUP_DIR/workshopsdb-$ts.dump"
mkdir -p "$BACKUP_DIR"

# 1. Export (connexion locale au conteneur : aucun mot de passe ne transite)
docker exec "$DB_CONTAINER" \
  pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc > "$file.tmp"
mv "$file.tmp" "$file"

# 2. Contrôle : l'archive doit être lisible par pg_restore
docker exec -i "$DB_CONTAINER" pg_restore --list < "$file" > /dev/null

# 3. Empreinte pour vérifier l'intégrité après copie hors site
(cd "$BACKUP_DIR" && \
  sha256sum "$(basename "$file")" > "$(basename "$file").sha256")

# 4. Rétention locale
find "$BACKUP_DIR" -name 'workshopsdb-*.dump*' -mtime +"$RETENTION_DAYS" -delete

echo "Sauvegarde OK : $file ($(du -h "$file" | cut -f1))"
