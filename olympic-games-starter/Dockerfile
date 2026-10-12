# ---------- Étape 1 : build de l'application Angular ----------
# Angular 20 requiert Node ^20.19 || ^22.12 || >=24
FROM node:22-alpine AS build

WORKDIR /usr/src/app

# Installation des dépendances (couche mise en cache tant que les manifests ne changent pas)
COPY package.json package-lock.json ./
RUN npm ci --cache .npm --prefer-offline

# Copie des sources et build de production
COPY . .
RUN npm run build

# ---------- Étape 2 : service des fichiers statiques avec Nginx ----------
FROM nginx:1.27-alpine

# Configuration fournie dans le dossier nginx/ (racine de l'application : /app)
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Le builder @angular/build:application place les fichiers servis dans le sous-dossier browser/
COPY --from=build /usr/src/app/dist/olympic-games-starter/browser /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
