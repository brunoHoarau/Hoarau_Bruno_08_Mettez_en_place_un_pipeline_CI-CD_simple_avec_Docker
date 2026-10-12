# Stratégie de tests

## Sommaire

### 1. Introduction

### 2. Tests unitaires

#### 2.1 Périmètre et objectifs

#### 2.2 Outils et technologies

#### 2.3 Critères de réussite

#### 2.4 Commandes d'exécution et rapports

#### 2.5 Fréquence d'exécution

### 3. Tests d'intégration

#### 3.1 Périmètre et objectifs

#### 3.2 Outils et technologies recommandés

#### 3.3 Scénarios de test prioritaires

#### 3.4 Critères de réussite

#### 3.5 Fréquence d'exécution recommandée

### 4. Tests End-to-End (E2E)

#### 4.1 Périmètre et objectifs

#### 4.2 Outils et technologies recommandés

#### 4.3 Scénarios E2E prioritaires

#### 4.4 Critères de réussite

#### 4.5 Fréquence d'exécution recommandée

### 5. Tests de performance

#### 5.1 Périmètre et objectifs

#### 5.2 Outils et technologies recommandés

#### 5.3 Métriques et seuils recommandés

#### 5.4 Scénarios de charge

#### 5.5 Fréquence d'exécution recommandée

### 6. Tests de sécurité

#### 6.1 Périmètre et objectifs

#### 6.2 Outils et technologies recommandés

#### 6.3 Vulnérabilités à vérifier en priorité

#### 6.4 Critères de réussite recommandés

#### 6.5 Fréquence d'exécution recommandée

### 7. Tests de contrat d'API

#### 7.1 Périmètre et objectifs

#### 7.2 Outils et technologies recommandés

#### 7.3 Scénarios prioritaires

#### 7.4 Critères de réussite

#### 7.5 Fréquence d'exécution

### 8. Fonctionnalités à tester

### 9. Fonctionnalités à ne pas tester

### 10. Stratégie CI/CD

#### 10.1 Déclenchement des tests

#### 10.2 Pipeline Angular

#### 10.3 Pipeline Java

#### 10.4 Tests d'intégration

#### 10.5 Tests E2E

#### 10.6 Tests de sécurité

#### 10.7 Conditions de validation et de déploiement

### 11. Matrice récapitulative des tests

### Notes et références

---

# 1. Introduction

L'objectif de cette stratégie est de définir une démarche de tests permettant de garantir la qualité, la fiabilité, la sécurité et les performances de l'application tout au long du processus d'intégration et de livraison continue.

L'application est composée de deux parties principales :

* un **front-end Angular** ;
* un **back-end Java / Spring Boot** communiquant avec une base de données **PostgreSQL**.

L'architecture générale peut être représentée ainsi :

```text
Utilisateur
    │
    ▼
Application Angular
    │
    │ HTTP / API REST
    ▼
Application Java / Spring Boot
    │
    ▼
PostgreSQL
```

La stratégie couvre plusieurs niveaux de tests :

1. tests unitaires ;
2. tests d'intégration ;
3. tests End-to-End ;
4. tests de performance ;
5. tests de sécurité ;
6. tests de contrat d'API.

L'objectif est d'automatiser autant que possible ces contrôles dans la chaîne CI/CD.

### Authentification

L'application ne possède actuellement **aucun système d'identification ou d'authentification utilisateur**.

Il n'y a donc pas :

* de connexion utilisateur ;
* de gestion de comptes ;
* de JWT ;
* de refresh token ;
* de gestion de session utilisateur ;
* de rôles ou permissions utilisateur.

La seule authentification présente concerne la **connexion de l'application à PostgreSQL**, via les paramètres de connexion à la base de données.

Les tests JWT et d'authentification utilisateur sont donc **hors périmètre**.

---

# 2. Tests unitaires

## 2.1 Périmètre et objectifs

Les tests unitaires vérifient individuellement les différentes unités de code.

### Angular

Ils concernent notamment :

* les composants ;
* les services ;
* les fonctions de traitement ;
* les transformations de données ;
* la gestion des erreurs ;
* les interactions avec les services HTTP.

### Java

Ils concernent notamment :

* les services ;
* la logique métier ;
* les contrôleurs ;
* les validations ;
* les traitements des données ;
* la gestion des erreurs.

L'objectif est de détecter rapidement les régressions avant les tests d'un niveau supérieur.

---

## 2.2 Outils et technologies

| Technologie | Outil            |
| ----------- | ---------------- |
| Angular     | Jasmine          |
| Angular     | Karma            |
| Java        | JUnit            |
| Java        | Mockito          |
| Java        | Gradle           |
| Spring Boot | Spring Boot Test |

Pour Angular, les tests doivent pouvoir être exécutés en CI avec :

```bash
ng test --watch=false --browsers=ChromeHeadless
```

Chrome Headless permet d'exécuter les tests sans interface graphique.

Pour Java :

```bash
./gradlew clean test
```

---

## 2.3 Critères de réussite

Les tests unitaires sont réussis lorsque :

* tous les tests critiques passent ;
* aucune régression n'est détectée ;
* les cas nominaux sont couverts ;
* les cas d'erreur importants sont couverts ;
* les nouveaux développements sont accompagnés de tests.

Une cible initiale de **80 % de couverture** peut être retenue, avec une couverture plus élevée pour les traitements métier critiques.

La couverture ne doit cependant pas être considérée comme le seul indicateur de qualité.

---

## 2.4 Commandes d'exécution et rapports

### Angular

```bash
npm ci
```

Puis :

```bash
ng test --watch=false --browsers=ChromeHeadless
```

### Java

```bash
./gradlew clean test
```

Les résultats des tests Java sont disponibles dans :

```text
build/test-results/test
```

---

## 2.5 Fréquence d'exécution

Les tests unitaires sont exécutés :

* à chaque commit ;
* à chaque Pull Request / Merge Request ;
* dans la CI ;
* avant chaque livraison.

---

# 3. Tests d'intégration

## 3.1 Périmètre et objectifs

Les tests d'intégration vérifient le fonctionnement de plusieurs composants ensemble.

Ils concernent notamment :

* Angular ↔ API ;
* API ↔ services métier ;
* API ↔ PostgreSQL ;
* sérialisation JSON ;
* validation des données ;
* gestion des erreurs HTTP.

---

## 3.2 Outils et technologies recommandés

| Besoin                  | Outil                 |
| ----------------------- | --------------------- |
| Tests Spring            | Spring Boot Test      |
| Tests API               | MockMvc               |
| Mock des dépendances    | Mockito               |
| Base PostgreSQL de test | Testcontainers        |
| Tests Angular HTTP      | HttpTestingController |
| Environnement           | Docker                |

### Testcontainers

**Testcontainers** est recommandé pour tester l'application avec une véritable instance PostgreSQL dans un conteneur.

Cela permet d'obtenir un environnement :

* reproductible ;
* isolé ;
* proche de la réalité ;
* indépendant de la configuration PostgreSQL du développeur.

Architecture :

```text
JUnit
  │
  ▼
Testcontainers
  │
  ▼
PostgreSQL
  │
  ▼
Spring Boot
```

---

## 3.3 Scénarios de test prioritaires

### TI-01 — Appel API valide

Vérifier :

* le code HTTP ;
* la structure JSON ;
* les données retournées.

### TI-02 — Données inexistantes

Vérifier le comportement lorsque la ressource demandée n'existe pas.

### TI-03 — Données invalides

Tester :

* champs obligatoires absents ;
* valeurs incorrectes ;
* formats invalides ;
* valeurs limites.

### TI-04 — Persistance PostgreSQL

Tester :

* création ;
* lecture ;
* modification ;
* suppression si applicable.

### TI-05 — Erreur API

Vérifier la gestion correcte des erreurs côté Angular.

### TI-06 — Connexion PostgreSQL

Vérifier que l'application :

* se connecte correctement ;
* utilise les bonnes variables de configuration ;
* gère correctement une indisponibilité de la base.

---

## 3.4 Critères de réussite

* aucun test critique en échec ;
* données correctement persistées ;
* réponses HTTP conformes ;
* erreurs correctement gérées ;
* environnement de test reproductible.

---

## 3.5 Fréquence d'exécution

Les tests d'intégration sont exécutés :

* dans la CI ;
* à chaque Pull Request ;
* avant chaque release ;
* après modification de l'API ;
* après modification du modèle de données.

---

# 4. Tests End-to-End (E2E)

## 4.1 Périmètre et objectifs

Les tests E2E vérifient l'application du point de vue d'un utilisateur.

Ils couvrent l'ensemble du parcours :

```text
Navigateur
    ↓
Angular
    ↓
API REST
    ↓
Spring Boot
    ↓
PostgreSQL
```

Ils permettent donc de vérifier que les différents composants fonctionnent correctement ensemble dans une situation proche de l'utilisation réelle.

---

## 4.2 Outils et technologies recommandés

### Cypress

Cypress est recommandé pour automatiser les parcours utilisateur dans le navigateur.

### Playwright

Playwright peut constituer une alternative à Cypress.

**Important :** Cypress et Playwright sont des outils proposés dans cette stratégie. Ils ne doivent pas être présentés comme déjà installés dans le repository s'ils ne le sont pas.

---

## 4.3 Scénarios E2E prioritaires

### E2E-01 — Chargement de l'application

Vérifier que :

* l'application démarre ;
* la page principale s'affiche ;
* les éléments essentiels sont présents.

### E2E-02 — Consultation des données

Vérifier :

* l'appel API ;
* la réception des données ;
* l'affichage des données.

### E2E-03 — Interaction utilisateur

Vérifier les principales actions disponibles dans l'application.

### E2E-04 — Erreur API

Simuler une erreur serveur et vérifier que l'interface réagit correctement.

### E2E-05 — API indisponible

Vérifier que l'application ne plante pas lorsque l'API n'est pas accessible.

### E2E-06 — Parcours complet

Valider le parcours :

```text
Action utilisateur
       ↓
Angular
       ↓
API
       ↓
PostgreSQL
       ↓
API
       ↓
Angular
       ↓
Résultat utilisateur
```

---

## 4.4 Critères de réussite

* aucun parcours critique en échec ;
* interface correctement affichée ;
* API correctement appelée ;
* données correctement affichées ;
* erreurs correctement gérées.

---

## 4.5 Fréquence

* tests E2E critiques : CI ;
* suite E2E complète : avant release ;
* régression E2E : après modification importante du front ou du back.

---

# 5. Tests de performance

## 5.1 Périmètre et objectifs

Les tests de performance permettent de vérifier le comportement de l'API sous différentes charges.

Ils portent notamment sur :

* temps de réponse ;
* nombre de requêtes ;
* concurrence ;
* utilisation CPU ;
* utilisation mémoire ;
* stabilité PostgreSQL.

---

## 5.2 Outils

Les outils recommandés sont :

* k6 ;
* Apache JMeter ;
* Lighthouse pour certains contrôles front-end.

---

## 5.3 Métriques et seuils

| Métrique      |          Seuil initial |
| ------------- | ---------------------: |
| Temps moyen   |               < 500 ms |
| P95           |                  < 1 s |
| P99           |                  < 2 s |
| Taux d'erreur |                  < 1 % |
| HTTP 5xx      | 0 sur scénario nominal |

Ces valeurs constituent des objectifs initiaux et devront être adaptées après mesure sur l'environnement cible.

---

## 5.4 Scénarios de charge

### TP-01 — Charge nominale

20 utilisateurs simultanés.

### TP-02 — Charge moyenne

50 utilisateurs simultanés.

### TP-03 — Montée en charge

```text
10 → 20 → 50 → 100 → 200 utilisateurs
```

### TP-04 — Endurance

Charge constante pendant une période prolongée.

---

## 5.5 Fréquence

* périodiquement ;
* avant une release importante ;
* après modification importante de l'API ;
* après modification de PostgreSQL.

---

# 6. Tests de sécurité

## 6.1 Périmètre et objectifs

Les tests de sécurité concernent :

* API ;
* entrées utilisateur ;
* PostgreSQL ;
* dépendances ;
* configuration ;
* secrets ;
* Docker/Kubernetes.

### Authentification

L'authentification utilisateur est **hors périmètre**, car elle n'est pas implémentée.

Il n'y aura donc pas de tests :

* JWT ;
* login ;
* logout ;
* refresh token ;
* session utilisateur ;
* rôles.

---

## 6.2 Outils

* OWASP ZAP ;
* npm audit ;
* OWASP Dependency-Check ;
* Snyk ;
* secret scanning ;
* analyse des images Docker.

---

## 6.3 Vulnérabilités prioritaires

### Injection

Tester les entrées susceptibles de provoquer des injections.

### Validation

Tester :

* valeurs vides ;
* caractères spéciaux ;
* chaînes trop longues ;
* types incorrects ;
* valeurs inattendues.

### Secrets

Vérifier qu'aucun :

* mot de passe ;
* token ;
* secret ;
* identifiant sensible

n'est présent dans le code source.

### Dépendances

Analyser les dépendances npm et Gradle.

### PostgreSQL

Vérifier la protection des identifiants de connexion et l'utilisation correcte des variables d'environnement.

---

## 6.4 Critères de réussite

* aucune vulnérabilité critique ;
* aucune fuite de secret ;
* entrées correctement validées ;
* erreurs ne révélant pas d'informations sensibles ;
* dépendances critiques corrigées.

---

## 6.5 Fréquence

* à chaque modification des dépendances ;
* dans la CI ;
* avant production ;
* périodiquement.

---

# 7. Tests de contrat d'API

## 7.1 Périmètre et objectifs

Les tests de contrat vérifient que le front-end Angular et le back-end Java respectent le même contrat d'API.

Ils sont particulièrement intéressants lorsque les deux repositories évoluent indépendamment.

Ils permettent de détecter une modification du back-end qui casserait le front-end.

---

## 7.2 Outils

**Pact** peut être utilisé pour mettre en place ces tests.

Il permet notamment de vérifier :

* endpoints ;
* méthodes HTTP ;
* paramètres ;
* structure JSON ;
* champs obligatoires ;
* codes HTTP ;
* réponses attendues.

---

## 7.3 Scénarios prioritaires

### TC-01 — Contrat d'une requête

Vérifier que l'API accepte la structure attendue par Angular.

### TC-02 — Contrat d'une réponse

Vérifier que la réponse contient les champs attendus.

### TC-03 — Code HTTP

Vérifier que l'API renvoie les codes attendus.

### TC-04 — Détection d'une rupture

Modifier volontairement le contrat et vérifier que le pipeline échoue.

---

## 7.4 Critères de réussite

Le test est réussi lorsque :

* Angular peut consommer l'API ;
* les structures JSON sont compatibles ;
* les codes HTTP correspondent ;
* aucune rupture de contrat n'est détectée.

---

## 7.5 Fréquence

Les tests de contrat peuvent être exécutés :

* dans la CI ;
* à chaque modification de l'API ;
* à chaque modification du modèle consommé par Angular ;
* avant déploiement.

Ils sont **recommandés**, mais ne sont pas indispensables si les deux applications sont toujours versionnées et déployées ensemble.

---

# 8. Fonctionnalités à tester

## P1 — Critiques

* chargement de l'application ;
* communication Angular/API ;
* principaux endpoints ;
* récupération des données ;
* enregistrement des données ;
* validation ;
* gestion des erreurs ;
* persistance PostgreSQL.

## P2 — Importantes

* navigation ;
* affichage des données ;
* gestion des résultats vides ;
* erreurs réseau ;
* performance des endpoints.

## P3 — Secondaires

* éléments visuels secondaires ;
* optimisations d'affichage ;
* comportements non critiques.

---

# 9. Fonctionnalités à ne pas tester

Les éléments suivants sont hors périmètre :

| Fonctionnalité                       | Justification                          |
| ------------------------------------ | -------------------------------------- |
| Login utilisateur                    | Non implémenté                         |
| JWT                                  | Non utilisé                            |
| Refresh token                        | Non utilisé                            |
| Session utilisateur                  | Non implémentée                        |
| Rôles utilisateur                    | Non implémentés                        |
| Permissions utilisateur              | Non implémentées                       |
| Réinitialisation de mot de passe     | Non implémentée                        |
| Fonctionnalités futures              | Non présentes dans la version actuelle |
| Fonctionnement interne d'Angular     | Hors responsabilité de l'application   |
| Fonctionnement interne de PostgreSQL | Hors responsabilité de l'application   |

---

# 10. Stratégie CI/CD

## 10.1 Déclenchement

Le pipeline doit être déclenché :

* lors d'un commit ;
* lors d'une Pull Request / Merge Request ;
* avant une release ;
* avant un déploiement.

---

## 10.2 Pipeline Angular

```text
npm ci
   ↓
Tests unitaires
   ↓
Chrome Headless
   ↓
Build Angular
```

Commande :

```bash
ng test --watch=false --browsers=ChromeHeadless
```

---

## 10.3 Pipeline Java

```text
Gradle
  ↓
Compilation
  ↓
Tests JUnit
  ↓
Rapports
```

Commande :

```bash
./gradlew clean test
```

---

## 10.4 Tests d'intégration

```text
CI
 ↓
Spring Boot
 ↓
Testcontainers
 ↓
PostgreSQL
 ↓
Tests intégration
```

---

## 10.5 Tests E2E

```text
Build application
       ↓
Démarrage Angular
       ↓
Démarrage API
       ↓
PostgreSQL
       ↓
Cypress
       ↓
Résultats
```

Les tests E2E critiques doivent empêcher la livraison en cas d'échec.

---

## 10.6 Tests de sécurité

Le pipeline peut intégrer :

```text
Dependency Scan
       ↓
Secret Scan
       ↓
Analyse sécurité
       ↓
OWASP ZAP
```

Les vulnérabilités critiques doivent bloquer le pipeline.

---

## 10.7 Conditions de validation et de déploiement

Une livraison est autorisée uniquement si :

* tests unitaires OK ;
* tests d'intégration OK ;
* tests E2E critiques OK ;
* aucune vulnérabilité critique ;
* build OK ;
* contrat API respecté lorsqu'il est activé.

---

# 11. Matrice récapitulative des tests

| ID     | Type        | Élément testé             | Outil                        | Priorité | Fréquence     |
| ------ | ----------- | ------------------------- | ---------------------------- | -------- | ------------- |
| TU-01  | Unitaire    | Composants Angular        | Jasmine/Karma                | P1       | Chaque commit |
| TU-02  | Unitaire    | Services Angular          | Jasmine/Karma                | P1       | Chaque commit |
| TU-03  | Unitaire    | Services Java             | JUnit/Mockito                | P1       | Chaque commit |
| TU-04  | Unitaire    | Validation métier         | JUnit                        | P1       | Chaque commit |
| CI-01  | CI/CD       | Angular Headless          | Chrome Headless              | P1       | Chaque commit |
| TI-01  | Intégration | API REST                  | Spring Boot Test             | P1       | CI            |
| TI-02  | Intégration | API + PostgreSQL          | Testcontainers               | P1       | CI            |
| TI-03  | Intégration | Angular + API             | HttpTestingController        | P1       | CI            |
| TI-04  | Intégration | Gestion erreurs           | JUnit/Karma                  | P1       | CI            |
| E2E-01 | E2E         | Chargement application    | Cypress                      | P1       | CI            |
| E2E-02 | E2E         | Consultation données      | Cypress                      | P1       | CI            |
| E2E-03 | E2E         | Parcours utilisateur      | Cypress                      | P1       | CI            |
| E2E-04 | E2E         | Erreur API                | Cypress                      | P1       | CI            |
| E2E-05 | E2E         | API indisponible          | Cypress                      | P2       | Release       |
| TC-01  | Contrat     | Requêtes API              | Pact                         | P2       | CI            |
| TC-02  | Contrat     | Réponses API              | Pact                         | P2       | CI            |
| TC-03  | Contrat     | Compatibilité Angular/API | Pact                         | P2       | CI            |
| TP-01  | Performance | API sous charge           | k6/JMeter                    | P2       | Hebdomadaire  |
| TP-02  | Performance | Endurance                 | k6/JMeter                    | P2       | Release       |
| TS-01  | Sécurité    | Dépendances               | npm audit / Dependency-Check | P1       | CI            |
| TS-02  | Sécurité    | API                       | OWASP ZAP                    | P1       | Release       |
| TS-03  | Sécurité    | Entrées                   | OWASP ZAP                    | P1       | Release       |
| TS-04  | Sécurité    | Secrets                   | Secret Scanning              | P1       | Chaque commit |
| TR-01  | Régression  | Fonctionnalités critiques | Tous les tests               | P1       | Release       |

---

# Notes et références

Les outils doivent être distingués entre ceux déjà présents dans les repositories et ceux proposés dans cette stratégie.

### Outils déjà liés au projet

* Angular ;
* Jasmine ;
* Karma ;
* npm ;
* Java ;
* Spring Boot ;
* JUnit ;
* Gradle ;
* PostgreSQL ;
* Docker / environnement conteneurisé.

### Outils recommandés à ajouter ou à envisager

* Chrome Headless pour la CI Angular ;
* Testcontainers pour les tests PostgreSQL ;
* Cypress ou Playwright pour les tests E2E ;
* Pact pour les tests de contrat ;
* k6 ou JMeter pour les tests de performance ;
* OWASP ZAP pour la sécurité ;
* outils d'analyse des dépendances et des secrets.

### Principe général

La stratégie privilégie une pyramide de tests :

```text
                /\
               /  \
              / E2E\
             /------\
            /Contrat \
           /----------\
          /Intégration \
         /--------------\
        / Tests unitaires\
       /__________________\
```

Les tests unitaires sont nombreux et rapides. Les tests d'intégration sont moins nombreux mais vérifient les interactions entre composants. Les tests E2E sont réservés aux parcours utilisateurs importants. Les tests de performance et de sécurité sont exécutés selon leur coût et leur fréquence appropriée.

L'objectif est d'obtenir une chaîne CI/CD capable de détecter automatiquement les régressions avant la livraison tout en conservant un temps d'exécution raisonnable.
