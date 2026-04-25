# ============================================================
#  seed-data.sh — Injection des données de démonstration GLPI
#  TP Final — Intégration Logicielle — M2 ISIE IBAM
#  Groupe 6
# ============================================================

echo "⏳ Injection des données GLPI dans MariaDB..."

docker exec -i mariadb mysql -u glpi_user -pglpi_pass_2024 glpi << 'SQL'

-- Tickets
INSERT IGNORE INTO glpi_tickets
    (name, content, status, priority, urgency, impact, date_creation, date_mod, entities_id, is_deleted, itilcategories_id)
VALUES
    ('Problème réseau bureau 3',    'Le réseau est inaccessible au bureau 3',       1, 4, 3, 3, NOW(),                   NOW(), 1, 0, 0),
    ('PC ne démarre plus',          'Ordinateur bloqué au démarrage',               2, 5, 4, 4, NOW() - INTERVAL 1 DAY,  NOW(), 1, 0, 0),
    ('Mise à jour Windows bloquée', 'Windows Update échoue erreur 0x80070005',      4, 3, 2, 2, NOW() - INTERVAL 2 DAY,  NOW(), 1, 0, 0),
    ('Imprimante hors service',     'Imprimante HP ne répond plus',                 5, 2, 2, 2, NOW() - INTERVAL 5 DAY,  NOW(), 1, 0, 0),
    ('Accès VPN impossible',        'Connexion VPN échoue depuis le domicile',      6, 4, 3, 3, NOW() - INTERVAL 10 DAY, NOW(), 1, 0, 0),
    ('Écran noir après veille',     'Écran ne se rallume pas après mise en veille', 1, 3, 2, 2, NOW() - INTERVAL 3 DAY,  NOW(), 1, 0, 0),
    ('Messagerie Outlook bloquée',  'Outlook ne se synchronise plus',               2, 4, 3, 3, NOW() - INTERVAL 4 DAY,  NOW(), 1, 0, 0),
    ('Mot de passe oublié',         'Réinitialisation mot de passe utilisateur',    5, 1, 1, 1, NOW() - INTERVAL 7 DAY,  NOW(), 1, 0, 0),
    ('Antivirus expiré',            'Licence antivirus à renouveler',               3, 3, 2, 2, NOW() - INTERVAL 15 DAY, NOW(), 1, 0, 0),
    ('Disque dur presque plein',    'Espace disque critique sur serveur fichiers',   2, 5, 5, 5, NOW() - INTERVAL 1 DAY,  NOW(), 1, 0, 0);

-- Ordinateurs
INSERT IGNORE INTO glpi_computers
    (name, serial, entities_id, is_deleted, is_template, users_id, date_creation, date_mod)
VALUES
    ('PC-IBAM-001',      'SN001IBAM', 1, 0, 0, 0, NOW(),                   NOW()),
    ('PC-IBAM-002',      'SN002IBAM', 1, 0, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('PC-IBAM-003',      'SN006IBAM', 1, 0, 0, 0, NOW() - INTERVAL 2 DAY,  NOW()),
    ('PC-IBAM-004',      'SN007IBAM', 1, 0, 0, 0, NOW() - INTERVAL 8 DAY,  NOW()),
    ('LAPTOP-ADMIN-01',  'SN003IBAM', 1, 0, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('LAPTOP-PROF-01',   'SN008IBAM', 1, 0, 0, 0, NOW() - INTERVAL 12 DAY, NOW()),
    ('PC-SALLE-INFO-01', 'SN004IBAM', 1, 0, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('PC-SALLE-INFO-02', 'SN005IBAM', 1, 0, 0, 0, NOW() - INTERVAL 20 DAY, NOW()),
    ('SERVEUR-IBAM-01',  'SN010IBAM', 1, 0, 0, 0, NOW() - INTERVAL 25 DAY, NOW()),
    ('SERVEUR-IBAM-02',  'SN011IBAM', 1, 0, 0, 0, NOW() - INTERVAL 30 DAY, NOW());

-- Périphériques
INSERT IGNORE INTO glpi_peripherals
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('IMPRIMANTE-HP-01',    'PER001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('IMPRIMANTE-HP-02',    'PER002IBAM', 1, 0, 0, NOW() - INTERVAL 3 DAY,  NOW()),
    ('SCANNER-CANON-01',    'PER003IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('ECRAN-DELL-01',       'PER004IBAM', 1, 0, 0, NOW() - INTERVAL 7 DAY,  NOW()),
    ('ECRAN-DELL-02',       'PER005IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('CLAVIER-LOGITECH-01', 'PER006IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('SOURIS-LOGITECH-01',  'PER007IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('WEBCAM-LOGITECH-01',  'PER008IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW()),
    ('DISQUE-EXTERNE-01',   'PER009IBAM', 1, 0, 0, NOW() - INTERVAL 25 DAY, NOW()),
    ('PROJECTEUR-EPSON-01', 'PER010IBAM', 1, 0, 0, NOW() - INTERVAL 30 DAY, NOW());

-- Équipements réseau
INSERT IGNORE INTO glpi_networkequipments
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('SWITCH-IBAM-01',  'NET001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('SWITCH-IBAM-02',  'NET002IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('ROUTEUR-IBAM-01', 'NET003IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('BORNE-WIFI-01',   'NET004IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('BORNE-WIFI-02',   'NET005IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW());

-- Imprimantes
INSERT IGNORE INTO glpi_printers
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('PRINTER-HP-LASER-01',  'PRN001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('PRINTER-HP-LASER-02',  'PRN002IBAM', 1, 0, 0, NOW() - INTERVAL 7 DAY,  NOW()),
    ('PRINTER-CANON-INK-01', 'PRN003IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('PRINTER-EPSON-01',     'PRN004IBAM', 1, 0, 0, NOW() - INTERVAL 21 DAY, NOW());

-- Téléphones
INSERT IGNORE INTO glpi_phones
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('TEL-BUREAU-ADMIN', 'PHN001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('TEL-BUREAU-DIR',   'PHN002IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('TEL-SALLE-CONF',   'PHN003IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW());

SQL

echo ""
echo "✅ Données injectées avec succès !"
echo ""
docker exec -i mariadb mysql -u glpi_user -pglpi_pass_2024 glpi -e "
SELECT 'Tickets'        AS type, COUNT(*) AS total FROM glpi_tickets         WHERE is_deleted=0
UNION ALL
SELECT 'Ordinateurs',            COUNT(*)          FROM glpi_computers        WHERE is_deleted=0
UNION ALL
SELECT 'Périphériques',          COUNT(*)          FROM glpi_peripherals      WHERE is_deleted=0
UNION ALL
SELECT 'Équip. réseau',          COUNT(*)          FROM glpi_networkequipments WHERE is_deleted=0
UNION ALL
SELECT 'Imprimantes',            COUNT(*)          FROM glpi_printers         WHERE is_deleted=0
UNION ALL
SELECT 'Téléphones',             COUNT(*)          FROM glpi_phones           WHERE is_deleted=0;"