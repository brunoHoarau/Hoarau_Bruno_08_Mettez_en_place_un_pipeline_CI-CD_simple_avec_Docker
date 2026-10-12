#!/usr/bin/env bash
#
# Exécute les tests unitaires en s'adaptant au type de projet et rassemble
# les rapports JUnit XML dans test-results/<projet>/ (exploitables par GitHub Actions).
#
# Usage :
#   ./run-tests.sh                      # teste les deux applications (front + back)
#   ./run-tests.sh <dossier> [...]      # teste uniquement les projets indiqués
#
# Variables d'environnement :
#   RESULTS_DIR   répertoire des rapports (défaut : <racine du script>/test-results)
#
# Code de sortie : 0 si tous les projets passent, 1 sinon.
#
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${RESULTS_DIR:-$ROOT_DIR/test-results}"
DEFAULT_PROJECTS=("$ROOT_DIR/olympic-games-starter" "$ROOT_DIR/workshop-organizer")

log()  { echo ">> $*"; }
err()  { echo "!! $*" >&2; }

# Vérifie qu'une commande est disponible dans le PATH
require() {
    if ! command -v "$1" >/dev/null 2>&1; then
        err "Dépendance manquante : '$1' introuvable dans le PATH"
        return 1
    fi
}

# Copie les rapports JUnit XML d'un dossier source vers le dossier de résultats
collect_reports() {
    local src="$1" dest="$2"
    mkdir -p "$dest"
    shopt -s nullglob
    local files=("$src"/*.xml)
    shopt -u nullglob
    if (( ${#files[@]} == 0 )); then
        err "Aucun rapport JUnit XML trouvé dans $src"
        return 1
    fi
    cp "${files[@]}" "$dest"/
    log "${#files[@]} rapport(s) JUnit copié(s) dans $dest"
}

# ---------- Projet Java / Gradle (Workshop Organizer) ----------
run_gradle() {
    local dest="$1"
    require java || return 1
    chmod +x ./gradlew

    log "Projet Gradle détecté — exécution : ./gradlew clean test"
    # 'clean' supprime build/test-results des exécutions précédentes
    local status=0
    ./gradlew clean test || status=$?

    # On collecte les rapports même en cas d'échec : ils décrivent les tests en erreur
    collect_reports "build/test-results/test" "$dest" || status=1
    return $status
}

# ---------- Projet Node / Angular (Olympic Participation Tracker) ----------
run_npm() {
    local dest="$1"
    if ! grep -q '"test"' ./package.json; then
        err "package.json trouvé mais sans script \"test\""
        return 1
    fi
    require node || return 1
    require npm  || return 1
    if [[ -z "${CHROME_BIN:-}" ]] && ! command -v google-chrome >/dev/null 2>&1 \
        && ! command -v chromium >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
        log "Attention : Chrome non trouvé dans le PATH (définir CHROME_BIN si Karma ne le détecte pas)"
    fi

    if [[ ! -d "./node_modules" ]]; then
        log "node_modules absent — installation (npm ci)"
        npm ci --cache .npm --prefer-offline || return 1
    fi

    # Nettoyage des rapports Karma précédents (outputDir 'reports' dans karma.conf.js)
    rm -rf ./reports

    log "Projet npm détecté — exécution : npm test"
    local status=0
    npm test || status=$?

    collect_reports "reports" "$dest" || status=1
    return $status
}

# Teste un projet dans un sous-shell pour isoler le changement de répertoire
run_project() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        err "Dossier introuvable : $dir"
        return 1
    fi
    local name dest
    name="$(basename "$(cd "$dir" && pwd)")"
    dest="$RESULTS_DIR/$name"

    (
        cd "$dir" || exit 1
        log "===== $name ($(pwd)) ====="
        if [[ -f "./gradlew" && -f "./build.gradle" ]]; then
            run_gradle "$dest"
        elif [[ -f "./package.json" ]]; then
            run_npm "$dest"
        else
            err "Type de projet non reconnu (ni build.gradle+gradlew, ni package.json) dans $(pwd)"
            exit 1
        fi
    )
}

# ---------- Programme principal ----------
if (( $# > 0 )); then
    projects=("$@")
else
    projects=("${DEFAULT_PROJECTS[@]}")
fi

# Nettoyage des résultats de l'exécution précédente
rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

failed=()
for project in "${projects[@]}"; do
    if run_project "$project"; then
        log "OK : $project"
    else
        err "ÉCHEC : $project"
        failed+=("$project")
    fi
done

echo
log "Rapports JUnit disponibles dans : $RESULTS_DIR"
if (( ${#failed[@]} > 0 )); then
    err "${#failed[@]} projet(s) en échec : ${failed[*]}"
    exit 1
fi
log "Tous les tests sont passés (${#projects[@]} projet(s))"
exit 0
