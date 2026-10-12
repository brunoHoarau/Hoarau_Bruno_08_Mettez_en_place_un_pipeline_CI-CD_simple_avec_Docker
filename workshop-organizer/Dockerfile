# ---------- Étape 1 : build + tests (Gradle 8.7 / JDK 21) ----------
FROM gradle:8.7-jdk21 AS build

WORKDIR /app

# Cache des dépendances
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
COPY gradlew ./

# Conversion Windows CRLF -> Linux LF
RUN sed -i 's/\r$//' ./gradlew

# Rend le wrapper Gradle exécutable
RUN chmod +x ./gradlew

# Cache des dépendances
RUN ./gradlew dependencies --no-daemon || true

# Code source
COPY src ./src

# Tests + génération du WAR
RUN ./gradlew clean test bootWar --no-daemon


# ---------- Étape 2 : exécution (JRE 21) ----------
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /app/build/libs/*.war app.war

# Script de démarrage : lit le mot de passe depuis le secret Docker
COPY entrypoint.sh ./entrypoint.sh
RUN sed -i 's/\r$//' ./entrypoint.sh && chmod +x ./entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]