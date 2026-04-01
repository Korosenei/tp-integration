# TP Final — Intégration Logicielle
**Module : Intégration Logicielle M2 ISIE — IBAM / UJKZ**
**Enseignant : Charles BATIONO**

> **Groupe 6 :**
> - KOURAOGO W Joel Faïsal
> - PARE Kontama Léandre Bénilde
> - COULIBALY Abdoul Rachid
>
> *Master 2 ISIE — IBAM / UJKZ — Ouagadougou, Burkina Faso — 2025-2026*

---

## 📐 Architecture déployée

Ce projet déploie une stack complète d'intégration logicielle conteneurisée via Docker Compose :

```
┌─────────────────────────────────────────────────────────────────┐
│                        glpi_network                             │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │  MariaDB │◄───│   GLPI   │    │PostgreSQL│                  │
│  │  :3306   │    │  :8080   │    │  :5432   │                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│                                        ▲                        │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │cAdvisor  │───►│Prometheus│───►│ Grafana  │                  │
│  │  :8081   │    │  :9090   │    │  :3000   │                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
└─────────────────────────────────────────────────────────────────┘
```

| Service | Rôle |
|---|---|
| **MariaDB** | Base de données de GLPI (tickets, utilisateurs, inventaire) |
| **GLPI** | Système ITSM de gestion de parc informatique |
| **PostgreSQL** | Base relationnelle disponible comme datasource Grafana secondaire |
| **cAdvisor** | Collecte les métriques des conteneurs Docker en temps réel |
| **Prometheus** | Agrège et stocke les métriques de cAdvisor |
| **Grafana** | Visualise les données GLPI (MariaDB) et les métriques (Prometheus) |

---

## ✅ Prérequis

| Outil | Version minimale | Vérification |
|---|---|---|
| Docker Desktop | 24.x | `docker --version` |
| Docker Compose | 2.x (inclus dans Docker Desktop) | `docker compose version` |
| RAM disponible | **4 Go minimum** (8 Go recommandé) | Gestionnaire des tâches Windows |
| OS testé | Windows 11 avec WSL2 activé | — |

> **Important :** Activer WSL2 dans Docker Desktop (Settings → General → Use WSL2 based engine).

---

## 🚀 Instructions de démarrage

### Étape 1 — Cloner le dépôt

```bash
git clone https://github.com/<votre-compte>/tp-integration.git
cd tp-integration
```

### Étape 2 — Créer le fichier de configuration

```bash
# Copier le modèle
copy .env.example .env

# Ouvrir dans VS Code pour adapter les mots de passe
code .env
```

### Étape 3 — Lancer la stack

```bash
docker compose up -d
```

Le premier démarrage télécharge les images (~2 Go). Prévoir 3-5 minutes.

### Étape 4 — Vérifier que tous les services sont UP

```bash
docker compose ps
```

Tous les services doivent afficher `running` ou `healthy`.

### Étape 5 — Suivre les logs GLPI (initialisation BDD ~1-2 min)

```bash
docker compose logs -f glpi
```

Attendre le message indiquant que GLPI est prêt avant de continuer.

### Étape 6 — Accéder aux interfaces

Voir la section **URLs d'accès** ci-dessous.

---

## 🌐 URLs d'accès aux services

| Service | URL | Description |
|---|---|---|
| **GLPI** | http://localhost:8080 | Interface de gestion ITSM |
| **Grafana** | http://localhost:3000 | Tableaux de bord |
| **Prometheus** | http://localhost:9090 | Interface de métriques |
| **cAdvisor** | http://localhost:8081 | Métriques brutes des conteneurs |
| **Prometheus Targets** | http://localhost:9090/targets | Statut des scrapers |

---

## 🔑 Identifiants par défaut

### GLPI
Après la première installation via le wizard (http://localhost:8080) :

| Identifiant | Valeur |
|---|---|
| Login | `glpi` |
| Mot de passe | `glpi` |

> **Note :** GLPI demande un wizard de configuration au premier lancement. Sélectionner MariaDB comme type de base, hôte `mariadb`, base `glpi`, utilisateur `glpi_user`.

### Grafana

| Identifiant | Valeur (configurée dans `.env`) |
|---|---|
| Login | `admin` |
| Mot de passe | `Admin@IBAM2024` |

---

## 🛑 Arrêt et nettoyage

### Arrêter la stack (données conservées)

```bash
docker compose down
```

### Arrêter et supprimer tous les volumes (reset complet)

```bash
docker compose down -v
```

### Supprimer également les images téléchargées

```bash
docker compose down -v --rmi all
```

---

## 📊 Partie 4 — Réponses aux questions PromQL

### Targets Prometheus configurés

Accéder à http://localhost:9090/targets pour voir le statut en temps réel.

| Job | Target | Statut attendu |
|---|---|---|
| `prometheus` | `localhost:9090` | ✅ UP |
| `cadvisor` | `cadvisor:8080` | ✅ UP |
| `glpi` | `glpi:80` | ⚠️ DOWN (GLPI n'expose pas de endpoint `/metrics` natif — normal) |

### Différence entre `scrape_interval` et `evaluation_interval`

- **`scrape_interval: 15s`** — Fréquence à laquelle Prometheus interroge (scrape) chaque target pour collecter de nouvelles métriques. C'est la granularité des données brutes.

- **`evaluation_interval: 15s`** — Fréquence à laquelle Prometheus évalue les règles d'alerte et les recording rules définies dans sa configuration. Ces deux valeurs sont indépendantes, bien qu'ici fixées à la même valeur pour la cohérence.

### Explication de la requête PromQL

```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m])
```

**Décomposition :**
- `container_cpu_usage_seconds_total` — Métrique cAdvisor comptant le temps CPU cumulé (en secondes) consommé par chaque conteneur depuis son démarrage. C'est un compteur monotone croissant.
- `{name!=""}` — Filtre pour n'afficher que les conteneurs ayant un nom (exclut les processus système sans nom).
- `[5m]` — Fenêtre temporelle de 5 minutes pour le calcul du taux.
- `rate(...)` — Calcule le taux d'accroissement par seconde sur la fenêtre de 5 minutes. Le résultat représente le **pourcentage de CPU utilisé** (une valeur de `0.5` = 50% d'un cœur).

**Interprétation :** Cette requête indique, pour chaque conteneur nommé, quelle fraction du CPU physique il consomme en moyenne sur les 5 dernières minutes. Multiplier par 100 donne un pourcentage.

---

## 🏗️ Structure du projet

```
tp-integration/
├── docker-compose.yml                  # Orchestration complète de la stack (6 services)
├── .env                                # Variables d'environnement (non committé)
├── .env.example                        # Modèle de configuration à copier
├── .gitignore                          # Fichiers exclus du dépôt Git
├── README.md                           # Documentation (ce fichier)
├── glpi/
│   └── config_db.php                   # Préconfiguration connexion GLPI → MariaDB
├── prometheus/
│   └── prometheus.yml                  # Configuration des scrapers Prometheus
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   ├── mariadb.yml             # Datasource GLPI-MariaDB (provisioning auto)
│   │   │   └── prometheus.yml          # Datasource Prometheus (provisioning auto)
│   │   └── dashboards/
│   │       └── dashboards.yml          # Provisioning automatique des dashboards
│   └── dashboards/
│       ├── glpi_dashboard.json         # Dashboard GLPI ITSM (6 panels)
│       └── monitoring_dashboard.json   # Dashboard monitoring Docker/cAdvisor (4 panels)
└── analyse/
    └── analyse_bdd_glpi.md             # Analyse SQL de la BDD GLPI (Partie 2, Q1→Q5)
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

*Rendu réalisé dans le cadre du TP Final d'Intégration Logicielle — M2 ISIE IBAM 2025-2026*