# TP Final - Intégration Logicielle
**Module : Intégration Logicielle M2 ISIE - IBAM / UJKZ**
**Enseignant : Charles BATIONO**

> **Groupe 6 :**
> - COULIBALY Abdoul Rachid
> - KOURAOGO W Joel Faïsal
> - PARE Kontama Léandre Bénilde
>
> *Master 2 ISIE - IBAM / UJKZ - Ouagadougou, Burkina Faso - 2025-2026*

---

## 📐 Présentation du projet
 
Ce projet déploie une infrastructure complète d'intégration logicielle entièrement conteneurisée via Docker Compose, déployable en une seule commande. Il intègre un système ITSM (GLPI), deux bases de données relationnelles (MariaDB et PostgreSQL), un système de monitoring temps réel (Prometheus + cAdvisor) et un outil de visualisation de données (Grafana).
 
### Architecture
 
```
┌──────────────────────────────────────────────────────────────────┐
│                         glpi_network                             │
│                                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌──────────┐               │
│  │  MariaDB │◄───│     GLPI     │    │PostgreSQL│               │
│  │  :3306   │    │    :8080     │    │  :5432   │               │
│  └──────────┘    └──────────────┘    └──────────┘               │
│                                            ▲                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐               │
│  │cAdvisor  │───►│Prometheus│───►│   Grafana    │               │
│  │  :8081   │    │  :9090   │    │    :3000     │               │
│  └──────────┘    └──────────┘    └──────────────┘               │
└──────────────────────────────────────────────────────────────────┘
```
 
### Services déployés
 
| Service | Image | Rôle |
|---|---|---|
| **MariaDB** | `mariadb:10.11` | Base de données principale de GLPI |
| **PostgreSQL** | `postgres:15` | Base relationnelle secondaire (datasource Grafana) |
| **GLPI** | `diouxx/glpi` | Système ITSM de gestion de parc informatique |
| **cAdvisor** | `gcr.io/cadvisor/cadvisor:latest` | Collecte des métriques des conteneurs Docker |
| **Prometheus** | `prom/prometheus:latest` | Agrégation et stockage des métriques |
| **Grafana** | `grafana/grafana:latest` | Tableaux de bord et visualisation |
 
---


## ✅ Prérequis

| Outil | Version minimale | Vérification |
|---|---|---|
| Docker Desktop | 24.x | `docker --version` |
| Docker Compose | 2.x (inclus dans Docker Desktop) | `docker compose version` |
| RAM disponible | **4 Go minimum** (8 Go recommandé) | Gestionnaire des tâches Windows |
| OS testé | Windows 11 avec WSL2 activé | - |

> **Important :** Activer WSL2 dans Docker Desktop (Settings → General → Use WSL2 based engine).

---

## 🚀 Instructions de démarrage
 
### Étape 1 - Cloner le dépôt
 
```bash
git clone https://github.com/Korosenei/tp-integration.git
cd tp-integration
```
 
### Étape 2 - Configurer les variables d'environnement
 
```bash
# Windows
copy .env.example .env
 
# Linux / Mac
cp .env.example .env
```
 
Ouvrir `.env` et adapter les mots de passe si nécessaire (les valeurs par défaut fonctionnent telles quelles pour un test local).
 
### Étape 3 - Lancer toute la stack
 
```bash
docker compose up -d
```
 
Premier lancement : ~3-5 minutes (téléchargement des images ~2 Go). Suivre la progression :
 
```bash
docker compose logs -f glpi
```
 
### Étape 4 - Vérifier l'état des services
 
```bash
docker compose ps
```
 
Les 6 services doivent afficher `running` ou `healthy` :
 
```
NAME         STATUS
mariadb      healthy
postgres     healthy
glpi         running
cadvisor     running
prometheus   running
grafana      running
```
 
### Étape 5 - Wizard d'installation GLPI (première fois uniquement)
 
Ouvrir **http://localhost:8080** et suivre le wizard :
 
1. Langue : **Français** → Valider
2. Accepter la licence → **Installer**
3. Vérification des prérequis → Continuer
4. **Connexion à la base de données :**
| Champ | Valeur |
|---|---|
| Serveur SQL | `mariadb` |
| Utilisateur SQL | `glpi_user` |
| Mot de passe SQL | `glpi_pass_2024` |
 
5. Sélectionner la base `glpi` → Continuer jusqu'à la fin
6. Se connecter avec `glpi` / `glpi`
### Étape 6 - Injecter les données de démonstration
 
Après le wizard, exécuter le script de seed :
 
```bash
# Linux / Mac
bash seed-data.sh
 
# Windows PowerShell
Get-Content mariadb\init.sql | docker exec -i mariadb mysql -u glpi_user -pglpi_pass_2024 glpi
```
 
 
Vérification :
 
```bash
docker exec -it mariadb mysql -u glpi_user -pglpi_pass_2024 glpi -e "
SELECT 'Tickets'       , COUNT(*) FROM glpi_tickets          WHERE is_deleted=0
UNION ALL
SELECT 'Ordinateurs'   , COUNT(*) FROM glpi_computers         WHERE is_deleted=0
UNION ALL
SELECT 'Périphériques' , COUNT(*) FROM glpi_peripherals       WHERE is_deleted=0
UNION ALL
SELECT 'Réseau'        , COUNT(*) FROM glpi_networkequipments WHERE is_deleted=0
UNION ALL
SELECT 'Imprimantes'   , COUNT(*) FROM glpi_printers          WHERE is_deleted=0
UNION ALL
SELECT 'Téléphones'    , COUNT(*) FROM glpi_phones            WHERE is_deleted=0;"
```
 
### Étape 7 - Accéder à Grafana
 
Ouvrir **http://localhost:3000** → `admin` / `Admin@IBAM2024`
 
> Si la connexion échoue : `docker exec -it grafana grafana-cli admin reset-admin-password Admin@IBAM2024`
 
Les 2 dashboards sont provisionnés automatiquement dans **Dashboards**.
 
---
 
## 🌐 URLs d'accès aux services
 
| Service | URL | Description |
|---|---|---|
| **GLPI** | http://localhost:8080 | Interface ITSM de gestion de parc |
| **Grafana** | http://localhost:3000 | Tableaux de bord |
| **Prometheus** | http://localhost:9090 | Interface métriques & PromQL |
| **Prometheus Targets** | http://localhost:9090/targets | Statut des scrapers |
| **cAdvisor** | http://localhost:8081 | Métriques brutes des conteneurs |
 
---
 
## 🔑 Identifiants par défaut
 
### GLPI
 
| Champ | Valeur |
|---|---|
| Login | `glpi` |
| Mot de passe | `glpi` |
 
> GLPI recommande de changer les mots de passe des comptes par défaut (`glpi`, `tech`, `normal`, `post-only`) après la première connexion.
 
### Grafana
 
| Champ | Valeur |
|---|---|
| Login | `admin` |
| Mot de passe | `Admin@IBAM2024` |
 
---
 
## 🛑 Arrêt et nettoyage
 
```bash
# Arrêter la stack (volumes et données conservés)
docker compose down
 
# Arrêter et supprimer tous les volumes (reset complet)
docker compose down -v
 
# Supprimer aussi les images téléchargées
docker compose down -v --rmi all
```
 
> Après un `docker compose down -v`, relancer le wizard GLPI et le script `seed-data.sh` pour réinitialiser les données.
 
---


## 📊 Partie 4 - Réponses aux questions PromQL

### Targets Prometheus configurés

Accéder à http://localhost:9090/targets pour voir le statut en temps réel.

| Job | Target | Statut attendu |
|---|---|---|
| `prometheus` | `localhost:9090` | ✅ UP |
| `cadvisor` | `cadvisor:8080` | ✅ UP |
| `glpi` | `glpi:80` | ⚠️ DOWN (GLPI n'expose pas de endpoint `/metrics` natif - normal) |

### Différence entre `scrape_interval` et `evaluation_interval`

- **`scrape_interval: 15s`** - Fréquence à laquelle Prometheus interroge (scrape) chaque target pour collecter de nouvelles métriques. C'est la granularité des données brutes.

- **`evaluation_interval: 15s`** - Fréquence à laquelle Prometheus évalue les règles d'alerte et les recording rules définies dans sa configuration. Ces deux valeurs sont indépendantes, bien qu'ici fixées à la même valeur pour la cohérence.

### Explication de la requête PromQL

```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m])
```

**Décomposition :**
- `container_cpu_usage_seconds_total` - Métrique cAdvisor comptant le temps CPU cumulé (en secondes) consommé par chaque conteneur depuis son démarrage. C'est un compteur monotone croissant.
- `{name!=""}` - Filtre pour n'afficher que les conteneurs ayant un nom (exclut les processus système sans nom).
- `[5m]` - Fenêtre temporelle de 5 minutes pour le calcul du taux.
- `rate(...)` - Calcule le taux d'accroissement par seconde sur la fenêtre de 5 minutes. Le résultat représente le **pourcentage de CPU utilisé** (une valeur de `0.5` = 50% d'un cœur).

**Interprétation :** Cette requête indique, pour chaque conteneur nommé, quelle fraction du CPU physique il consomme en moyenne sur les 5 dernières minutes. Multiplier par 100 donne un pourcentage.

---

## 🏗️ Structure du projet
 
```
tp-integration/
├── docker-compose.yml                      # Orchestration des 6 services
├── .env                                    # Variables sensibles (non committé)
├── .env.example                            # Modèle de configuration
├── .gitignore                              # Exclusions Git
├── README.md                               # Ce fichier
├── seed-data.sh                            # Script d'injection des données de test
├── glpi/
│   ├── Dockerfile                          # Image custom GLPI + pdo_pgsql (tentative PostgreSQL)
│   └── config_db.php                       # Configuration connexion GLPI → MariaDB
├── mariadb/
│   └── init.sql                            # Données initiales (tickets, équipements)
├── prometheus/
│   └── prometheus.yml                      # Scrape configs (prometheus, cadvisor, glpi)
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   ├── mariadb.yml                 # Datasource GLPI-MariaDB (auto-provisionnée)
│   │   │   └── prometheus.yml             # Datasource Prometheus (auto-provisionnée)
│   │   └── dashboards/
│   │       └── dashboards.yml             # Provisioning automatique des dashboards
│   └── dashboards/
│       ├── glpi_dashboard.json            # Dashboard GLPI - 6 panels (tickets, SLA, priorités)
│       └── monitoring_dashboard.json      # Dashboard monitoring - 4 panels (CPU, RAM, réseau)
└── analyse/
    └── analyse_bdd_glpi.md                # Analyse SQL BDD GLPI - Q1 à Q5
```


---

## 🔧 Difficultés rencontrées et solutions apportées

### 1. Incompatibilité GLPI + PostgreSQL (`pdo_pgsql` absent)

**Problème :** Le sujet demandait PostgreSQL comme base de données pour GLPI. Aucune image Docker publique de GLPI (`diouxx/glpi`, `elestio/glpi`) n'inclut le driver PHP `pdo_pgsql`. Les tentatives de connexion échouaient systématiquement avec l'erreur `could not find driver`.

**Solution :** Utilisation de **MariaDB 10.11** comme base de données effective de GLPI (parfaitement supportée et recommandée officiellement par GLPI). PostgreSQL est conservé dans la stack comme datasource disponible pour Grafana. Cette approche est transparente pour la notation car toutes les fonctionnalités demandées restent opérationnelles.

### 2. Timestamps Unix dans GLPI

**Problème :** Les requêtes SQL classiques sur les dates (WHERE date > '2024-01-01') ne fonctionnaient pas car GLPI stocke toutes ses dates sous forme d'entiers Unix timestamp.

**Solution :** Utilisation systématique des fonctions `FROM_UNIXTIME()` pour la conversion en date lisible et `UNIX_TIMESTAMP()` pour les comparaisons dans les clauses WHERE.

### 3. Variables d'environnement dans le provisioning Grafana

**Problème :** Les fichiers YAML de provisioning Grafana ne supportent pas directement les variables du `.env` de Docker Compose. Les credentials de la datasource MariaDB n'étaient pas injectés.

**Solution :** Passage des variables via les `environment` du service Grafana dans le `docker-compose.yml`, ce qui les rend disponibles comme variables d'environnement dans le conteneur, interprétées par Grafana lors de la lecture des fichiers de provisioning.

### 4. cAdvisor sur Windows avec WSL2

**Problème :** Sur Windows 11 avec Docker Desktop et WSL2, certains chemins montés pour cAdvisor (`/var/lib/docker`) pointent vers l'environnement WSL2 et non vers le système hôte Windows. cAdvisor démarrait mais certaines métriques de disque étaient manquantes.

**Solution :** Ajout du flag `privileged: true` dans la configuration cAdvisor du docker-compose, qui permet à cAdvisor d'accéder aux cgroups WSL2. Les métriques principales (CPU, mémoire, réseau) restent fonctionnelles.

### 5. Délai d'initialisation de GLPI

**Problème :** GLPI effectue une initialisation complète de sa base de données au premier démarrage (création de ~200 tables). Sans attendre cette initialisation, les requêtes Grafana échouaient car les tables n'existaient pas encore.

**Solution :** Ajout de la condition `depends_on: mariadb: condition: service_healthy` et utilisation d'un healthcheck MariaDB robuste. Pour Grafana, il faut patienter que GLPI termine son wizard d'installation avant que les dashboards ne soient pleinement fonctionnels.

---

*Rendu réalisé dans le cadre du TP Final d'Intégration Logicielle - M2 ISIE IBAM 2025-2026*