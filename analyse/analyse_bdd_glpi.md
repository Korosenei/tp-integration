# Analyse de la base de données GLPI
**TP Final — Intégration Logicielle — M2 ISIE IBAM / UJKZ**

**Groupe 6 :**
- COULIBALY Abdoul Rachid
- KOURAOGO W Joel Faïsal
- PARE Kontama Léandre Bénilde

---

## Connexion à la base de données

```bash
docker exec -it mariadb mysql -u glpi_user -pglpi_pass_2024 glpi
```

---

## Q1 — 10 tables principales de GLPI

| Table | Rôle |
|---|---|
| `glpi_tickets` | Table centrale du système ITSM. Contient tous les tickets d'incidents et demandes de service avec leurs attributs (statut, priorité, dates, description, catégorie). |
| `glpi_computers` | Inventaire des ordinateurs du parc informatique. Stocke le nom, le système d'exploitation, le fabricant, le numéro de série et les informations matérielles. |
| `glpi_users` | Référentiel des utilisateurs de GLPI (techniciens, demandeurs, admins). Contient identifiants, emails, rôles et préférences. |
| `glpi_entities` | Représente la structure organisationnelle hiérarchique (entités, sous-entités). Permet de segmenter la gestion par département ou site géographique. |
| `glpi_itilcategories` | Catalogue des catégories de tickets ITIL. Permet de classifier les incidents et demandes pour les statistiques et le routage. |
| `glpi_peripherals` | Inventaire des périphériques (claviers, souris, écrans, imprimantes). Structure similaire à `glpi_computers`. |
| `glpi_networkequipments` | Inventaire des équipements réseau (switches, routeurs, bornes Wi-Fi). Inclut adresses IP, modèles et emplacements. |
| `glpi_slms` | Définition des SLM (Service Level Management). Contient les niveaux de service avec leurs délais de réponse et résolution. |
| `glpi_tickets_users` | Table de liaison entre tickets et utilisateurs. Définit le rôle de chaque utilisateur sur un ticket (demandeur, technicien, observateur). |
| `glpi_ticketcosts` | Suivi des coûts associés aux tickets (temps de travail, matériels utilisés). Utile pour la facturation interne. |

---

## Q2 — Nombre de tickets par statut

### Référence des statuts GLPI

| Code | Libellé | Signification |
|---|---|---|
| 1 | Nouveau | Ticket créé, non encore pris en charge |
| 2 | En cours (attribué) | Ticket assigné à un technicien |
| 3 | En cours (planifié) | Ticket avec une intervention planifiée |
| 4 | En attente | En attente d'une action externe (utilisateur, fournisseur) |
| 5 | Résolu | Solution apportée, en attente de validation |
| 6 | Clos | Ticket validé et archivé |

### Requête SQL

```sql
-- Comptage des tickets par statut avec libellés lisibles
SELECT
    CASE status
        WHEN 1 THEN 'Nouveau'
        WHEN 2 THEN 'En cours (attribué)'
        WHEN 3 THEN 'En cours (planifié)'
        WHEN 4 THEN 'En attente'
        WHEN 5 THEN 'Résolu'
        WHEN 6 THEN 'Clos'
        ELSE CONCAT('Statut inconnu (', status, ')')
    END AS statut,
    COUNT(*) AS nombre_tickets
FROM glpi_tickets
WHERE is_deleted = 0          -- Exclure les tickets supprimés
GROUP BY status
ORDER BY status;
```

---

## Q3 — Tickets créés par mois (12 derniers mois)

```sql
-- Tickets créés par mois sur les 12 derniers mois
-- Note : GLPI stocke date_creation en timestamp Unix (entier)
SELECT
    DATE_FORMAT(date_creation, '%Y-%m') AS mois,
    COUNT(*)                            AS tickets_créés
FROM glpi_tickets
WHERE
    date_creation >= NOW() - INTERVAL 12 MONTH
    AND is_deleted = 0
GROUP BY DATE_FORMAT(date_creation, '%Y-%m')
ORDER BY mois ASC;
```

> **Note technique :** GLPI utilise des timestamps Unix (entiers de type `int`) et non des colonnes `DATETIME` natives. Il faut systématiquement utiliser `FROM_UNIXTIME()` pour convertir.

---

## Q4 — Équipements associés à un utilisateur

```sql
-- Ordinateurs associés à un utilisateur donné
-- Remplacer 'jdupont' par le login de l'utilisateur recherché
SELECT
    c.id                        AS id_ordinateur,
    c.name                      AS nom_ordinateur,
    c.serial                    AS numéro_série,
    c.otherserial               AS autre_référence,
    os.name                     AS système_exploitation,
    u.name                      AS login_utilisateur,
    CONCAT(u.firstname, ' ', u.realname) AS nom_complet
FROM glpi_computers c
INNER JOIN glpi_users u
    ON c.users_id = u.id
LEFT JOIN glpi_operatingsystems os
    ON c.operatingsystems_id = os.id
WHERE
    u.name = 'jdupont'          -- filtre par login utilisateur
    AND c.is_deleted = 0
ORDER BY c.name;

-- Variante : tous les équipements (ordinateurs + périphériques)
SELECT
    'Ordinateur'         AS type_équipement,
    c.name               AS nom,
    c.serial             AS série,
    CONCAT(u.firstname, ' ', u.realname) AS utilisateur
FROM glpi_computers c
INNER JOIN glpi_users u ON c.users_id = u.id
WHERE u.name = 'jdupont' AND c.is_deleted = 0

UNION ALL

SELECT
    'Périphérique'       AS type_équipement,
    p.name               AS nom,
    p.serial             AS série,
    CONCAT(u.firstname, ' ', u.realname) AS utilisateur
FROM glpi_peripherals p
INNER JOIN glpi_users u ON p.users_id = u.id
WHERE u.name = 'jdupont' AND p.is_deleted = 0;
```

---

## Q5 — Analyse des SLA (Service Level Agreements)

### Tables impliquées

| Table | Rôle |
|---|---|
| `glpi_slms` | Définit les SLM (Service Level Management) — contenant le nom, le type (temps de réponse ou résolution) et le calendrier associé |
| `glpi_slas` | Niveaux de service concrets avec leurs délais (durée en secondes) |
| `glpi_slalevels` | Niveaux d'escalade d'un SLA (paliers d'action avant dépassement) |
| `glpi_tickets` | Référence les SLA via `slas_id_ttr` (time to resolve) et `slas_id_tto` (time to own) |

### Relation entre `glpi_tickets` et `glpi_slms`

```
glpi_slms (définition SLM)
    └──> glpi_slas (niveaux de service, délais)
              └──> glpi_tickets.slas_id_ttr  (SLA résolution)
              └──> glpi_tickets.slas_id_tto  (SLA prise en charge)
```

### Requête : SLA respectés vs dépassés

```sql
-- Analyse du respect des SLA sur les tickets résolus
SELECT
    s.name                          AS nom_sla,
    COUNT(t.id)                     AS total_tickets,
    SUM(
        CASE
            -- SLA respecté si résolu avant la date limite SLA
            WHEN t.solvedate IS NOT NULL
             AND t.time_to_resolve IS NOT NULL
             AND t.solvedate <= t.time_to_resolve
            THEN 1 ELSE 0
        END
    )                               AS sla_respectés,
    SUM(
        CASE
            WHEN t.solvedate IS NOT NULL
             AND t.time_to_resolve IS NOT NULL
             AND t.solvedate > t.time_to_resolve
            THEN 1 ELSE 0
        END
    )                               AS sla_dépassés,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN t.solvedate <= t.time_to_resolve THEN 1 ELSE 0
            END
        ) / COUNT(t.id), 2
    )                               AS taux_respect_pct
FROM glpi_tickets t
LEFT JOIN glpi_slas s
    ON t.slas_id_ttr = s.id
WHERE
    t.status IN (5, 6)              -- tickets résolus ou clos
    AND t.is_deleted = 0
    AND s.id IS NOT NULL            -- uniquement les tickets avec SLA défini
GROUP BY s.id, s.name
ORDER BY taux_respect_pct ASC;     -- les SLA les moins respectés en premier
```

> **Explication du schéma :** `glpi_tickets.slas_id_ttr` contient l'ID du SLA de résolution (Time To Resolve), et `glpi_tickets.time_to_resolve` contient le timestamp Unix de l'échéance calculée. La comparaison avec `solvedate` permet de déterminer si le SLA a été respecté.
