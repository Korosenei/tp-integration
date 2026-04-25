-- ============================================================
--  Script d'initialisation automatique des données GLPI
--  TP Final — Intégration Logicielle — M2 ISIE IBAM
--  Groupe 6 :
--             COULIBALY Abdoul Rachid
--             KOURAOGO W Joel Faïsal
--             PARE Kontama Léandre Bénilde
-- ============================================================

USE glpi;

-- ============================================================
--  Nettoyage préalable des données existantes pour éviter les doublons
-- ============================================================
DELETE FROM glpi_softwarelicenses WHERE entities_id = 1;
DELETE FROM glpi_softwares         WHERE entities_id = 1;
DELETE FROM glpi_passivedcequipments WHERE name LIKE '%IBAM%' OR name LIKE '%BRASSAGE%' OR name LIKE '%CABLE%' OR name LIKE '%FIBRE%';
DELETE FROM glpi_pdus              WHERE entities_id = 1;
DELETE FROM glpi_enclosures        WHERE name LIKE '%IBAM%' OR name LIKE '%CHASSIS%';
DELETE FROM glpi_racks             WHERE entities_id = 1;
DELETE FROM glpi_phones            WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_printers          WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_networkequipments WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_peripherals       WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_monitors          WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_computers         WHERE serial LIKE '%IBAM%';
DELETE FROM glpi_tickets           WHERE date_creation >= NOW() - INTERVAL 31 DAY;

-- ============================================================
--  Tickets de support
-- ============================================================
INSERT IGNORE INTO glpi_tickets
    (name, content, status, priority, urgency, impact, date_creation, date_mod, entities_id, is_deleted, itilcategories_id)
VALUES
    ('Problème réseau bureau 3',    'Le réseau est inaccessible au bureau 3',            1, 4, 3, 3, NOW(),                        NOW(), 1, 0, 0),
    ('PC ne démarre plus',          'Ordinateur bloqué au démarrage',                    2, 5, 4, 4, NOW() - INTERVAL 1 DAY,       NOW(), 1, 0, 0),
    ('Mise à jour Windows bloquée', 'Windows Update échoue avec erreur 0x80070005',      4, 3, 2, 2, NOW() - INTERVAL 2 DAY,       NOW(), 1, 0, 0),
    ('Imprimante hors service',     'Imprimante HP ne répond plus',                      5, 2, 2, 2, NOW() - INTERVAL 5 DAY,       NOW(), 1, 0, 0),
    ('Accès VPN impossible',        'Connexion VPN échoue depuis le domicile',           6, 4, 3, 3, NOW() - INTERVAL 10 DAY,      NOW(), 1, 0, 0),
    ('Écran noir après veille',     'Écran ne se rallume pas après mise en veille',      1, 3, 2, 2, NOW() - INTERVAL 3 DAY,       NOW(), 1, 0, 0),
    ('Messagerie Outlook bloquée',  'Outlook ne se synchronise plus',                    2, 4, 3, 3, NOW() - INTERVAL 4 DAY,       NOW(), 1, 0, 0),
    ('Mot de passe oublié',         'Réinitialisation mot de passe utilisateur',         5, 1, 1, 1, NOW() - INTERVAL 7 DAY,       NOW(), 1, 0, 0),
    ('Antivirus expiré',            'Licence antivirus à renouveler',                    3, 3, 2, 2, NOW() - INTERVAL 15 DAY,      NOW(), 1, 0, 0),
    ('Disque dur presque plein',    'Espace disque critique sur serveur fichiers',        2, 5, 5, 5, NOW() - INTERVAL 1 DAY,       NOW(), 1, 0, 0);

-- ============================================================
--  Ordinateurs
-- ============================================================
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

-- ============================================================
--  Moniteurs (Écrans)
-- ============================================================
INSERT IGNORE INTO glpi_monitors
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('ECRAN-DELL-24-01',    'MON001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('ECRAN-DELL-24-02',    'MON002IBAM', 1, 0, 0, NOW() - INTERVAL 2 DAY,  NOW()),
    ('ECRAN-SAMSUNG-27-01', 'MON003IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('ECRAN-LG-22-01',      'MON004IBAM', 1, 0, 0, NOW() - INTERVAL 8 DAY,  NOW()),
    ('ECRAN-ACER-21-01',    'MON005IBAM', 1, 0, 0, NOW() - INTERVAL 12 DAY, NOW()),
    ('ECRAN-ASUS-24-01',    'MON006IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW());

-- ============================================================
--  Périphériques
-- ============================================================
INSERT IGNORE INTO glpi_peripherals
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('IMPRIMANTE-HP-01',     'PER001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('IMPRIMANTE-HP-02',     'PER002IBAM', 1, 0, 0, NOW() - INTERVAL 3 DAY,  NOW()),
    ('SCANNER-CANON-01',     'PER003IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('CLAVIER-LOGITECH-01',  'PER004IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('SOURIS-LOGITECH-01',   'PER005IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('WEBCAM-LOGITECH-01',   'PER006IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW()),
    ('DISQUE-EXTERNE-01',    'PER007IBAM', 1, 0, 0, NOW() - INTERVAL 25 DAY, NOW()),
    ('PROJECTEUR-EPSON-01',  'PER008IBAM', 1, 0, 0, NOW() - INTERVAL 30 DAY, NOW()),
    ('CLAVIER-MICROSOFT-01', 'PER009IBAM', 1, 0, 0, NOW() - INTERVAL 3 DAY,  NOW()),
    ('SOURIS-MICROSOFT-01',  'PER010IBAM', 1, 0, 0, NOW() - INTERVAL 4 DAY,  NOW()),
    ('CASQUE-JBL-01',        'PER011IBAM', 1, 0, 0, NOW() - INTERVAL 6 DAY,  NOW()),
    ('HUB-USB-01',           'PER012IBAM', 1, 0, 0, NOW() - INTERVAL 8 DAY,  NOW());

-- ============================================================
--  Équipements réseau
-- ============================================================
INSERT IGNORE INTO glpi_networkequipments
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('SWITCH-CISCO-2960-01',    'NET001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('SWITCH-CISCO-2960-02',    'NET002IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('ROUTEUR-CISCO-1921-01',   'NET003IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('BORNE-WIFI-UNIFI-01',     'NET004IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('BORNE-WIFI-UNIFI-02',     'NET005IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW()),
    ('SWITCH-HP-48P-01',        'NET006IBAM', 1, 0, 0, NOW() - INTERVAL 2 DAY,  NOW()),
    ('FIREWALL-PFSENSE-01',     'NET007IBAM', 1, 0, 0, NOW() - INTERVAL 7 DAY,  NOW()),
    ('MODEM-SFR-01',            'NET008IBAM', 1, 0, 0, NOW() - INTERVAL 12 DAY, NOW()),
    ('ROUTEUR-WIFI-TP-LINK-01', 'NET009IBAM', 1, 0, 0, NOW() - INTERVAL 18 DAY, NOW()),
    ('SWITCH-D-LINK-01',        'NET010IBAM', 1, 0, 0, NOW() - INTERVAL 25 DAY, NOW());

-- ============================================================
--  Imprimantes
-- ============================================================
INSERT IGNORE INTO glpi_printers
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('PRINTER-HP-LASERJET-01',   'PRN001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('PRINTER-HP-LASERJET-02',   'PRN002IBAM', 1, 0, 0, NOW() - INTERVAL 7 DAY,  NOW()),
    ('PRINTER-CANON-PIXMA-01',   'PRN003IBAM', 1, 0, 0, NOW() - INTERVAL 14 DAY, NOW()),
    ('PRINTER-EPSON-WF-01',      'PRN004IBAM', 1, 0, 0, NOW() - INTERVAL 21 DAY, NOW()),
    ('PRINTER-BROTHER-01',       'PRN005IBAM', 1, 0, 0, NOW() - INTERVAL 3 DAY,  NOW()),
    ('PRINTER-XEROX-01',         'PRN006IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('IMPRIMANTE-ETIQUETTES-01', 'PRN007IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('PLOTTER-HP-DESIGNJET-01',  'PRN008IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW());

-- ============================================================
--  Téléphones
-- ============================================================
INSERT IGNORE INTO glpi_phones
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('TEL-BUREAU-ADMIN',  'PHN001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('TEL-BUREAU-DIR',    'PHN002IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('TEL-SALLE-CONF',    'PHN003IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('TEL-ACCUEIL-01',    'PHN004IBAM', 1, 0, 0, NOW() - INTERVAL 2 DAY,  NOW()),
    ('TEL-MOBILE-PRO-01', 'PHN005IBAM', 1, 0, 0, NOW() - INTERVAL 8 DAY,  NOW()),
    ('TEL-MOBILE-PRO-02', 'PHN006IBAM', 1, 0, 0, NOW() - INTERVAL 12 DAY, NOW()),
    ('TEL-VISIOCONF-01',  'PHN007IBAM', 1, 0, 0, NOW() - INTERVAL 18 DAY, NOW());

-- ============================================================
--  Logiciels
-- ============================================================
INSERT IGNORE INTO glpi_softwares
    (name, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('Microsoft Office 365', 1, 0, 0, NOW(),                   NOW()),
    ('Windows 11 Pro',       1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('Antivirus Kaspersky',  1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('Adobe Acrobat Reader', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('VPN Cisco AnyConnect', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW()),
    ('7-Zip',                1, 0, 0, NOW() - INTERVAL 25 DAY, NOW()),
    ('Mozilla Firefox',      1, 0, 0, NOW() - INTERVAL 30 DAY, NOW());

-- ============================================================
--  Licences logicielles
--  Utilisation de sous-requêtes pour éviter les conflits d'ID
--  avec les données de démonstration existantes.
-- ============================================================
INSERT IGNORE INTO glpi_softwarelicenses
    (name, softwares_id, entities_id, is_deleted, number, date_creation, date_mod)
VALUES
    ('Licence Office 365 - Pack 10',
        (SELECT id FROM glpi_softwares WHERE name = 'Microsoft Office 365' LIMIT 1),
        1, 0, 10, NOW(),                   NOW()),
    ('Licence Windows 11 Pro - x5',
        (SELECT id FROM glpi_softwares WHERE name = 'Windows 11 Pro' LIMIT 1),
        1, 0,  5, NOW() - INTERVAL 5 DAY,  NOW()),
    ('Licence Kaspersky - x20',
        (SELECT id FROM glpi_softwares WHERE name = 'Antivirus Kaspersky' LIMIT 1),
        1, 0, 20, NOW() - INTERVAL 10 DAY, NOW()),
    ('Licence Adobe Reader - x15',
        (SELECT id FROM glpi_softwares WHERE name = 'Adobe Acrobat Reader' LIMIT 1),
        1, 0, 15, NOW() - INTERVAL 15 DAY, NOW()),
    ('Licence VPN AnyConnect - x8',
        (SELECT id FROM glpi_softwares WHERE name = 'VPN Cisco AnyConnect' LIMIT 1),
        1, 0,  8, NOW() - INTERVAL 20 DAY, NOW());

-- ============================================================
--  Baies (Racks)
--  Colonnes valides dans glpi_racks :
--  name, entities_id, is_deleted, date_creation, date_mod, number_units
--  (serial et is_template ne sont PAS des colonnes de cette table)
-- ============================================================
INSERT IGNORE INTO glpi_racks
    (name, entities_id, is_deleted, date_creation, date_mod, number_units)
VALUES
    ('BAIE-SERVEUR-01',    1, 0, NOW(),                   NOW(), 42),
    ('BAIE-RESEAU-01',     1, 0, NOW() - INTERVAL 5 DAY,  NOW(), 24),
    ('BAIE-TELECOM-01',    1, 0, NOW() - INTERVAL 10 DAY, NOW(), 24),
    ('BAIE-PRODUCTION-01', 1, 0, NOW() - INTERVAL 15 DAY, NOW(), 42),
    ('BAIE-SECOURS-01',    1, 0, NOW() - INTERVAL 20 DAY, NOW(), 12);

-- ============================================================
--  Châssis / Boîtiers lames
--  Table correcte dans GLPI : glpi_enclosures (et non glpi_chassis)
-- ============================================================
INSERT IGNORE INTO glpi_enclosures
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('CHASSIS-DELL-POWEREDGE-01', 'ENC001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('CHASSIS-HP-C7000-01',       'ENC002IBAM', 1, 0, 0, NOW() - INTERVAL 8 DAY,  NOW()),
    ('CHASSIS-CISCO-UCS-01',      'ENC003IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('CHASSIS-BLADE-IBM-01',      'ENC004IBAM', 1, 0, 0, NOW() - INTERVAL 22 DAY, NOW());

-- ============================================================
--  PDU (Unités de Distribution d'Énergie)
--  Colonnes valides dans glpi_pdus :
--  name, entities_id, is_deleted, date_creation, date_mod
--  (serial et is_template ne sont PAS des colonnes de cette table)
-- ============================================================
INSERT IGNORE INTO glpi_pdus
    (name, entities_id, is_deleted, date_creation, date_mod)
VALUES
    ('PDU-APC-01',       1, 0, NOW(),                   NOW()),
    ('PDU-APC-02',       1, 0, NOW() - INTERVAL 3 DAY,  NOW()),
    ('PDU-EATON-01',     1, 0, NOW() - INTERVAL 7 DAY,  NOW()),
    ('PDU-SCHNEIDER-01', 1, 0, NOW() - INTERVAL 12 DAY, NOW()),
    ('PDU-RIYI-01',      1, 0, NOW() - INTERVAL 18 DAY, NOW());

-- ============================================================
--  Équipements passifs (Câblage / Infrastructure réseau)
-- ============================================================
INSERT IGNORE INTO glpi_passivedcequipments
    (name, serial, entities_id, is_deleted, is_template, date_creation, date_mod)
VALUES
    ('BRASSAGE-RESEAU-01', 'PAS001IBAM', 1, 0, 0, NOW(),                   NOW()),
    ('BRASSAGE-RESEAU-02', 'PAS002IBAM', 1, 0, 0, NOW() - INTERVAL 5 DAY,  NOW()),
    ('BAIE-BRASSAGE-01',   'PAS003IBAM', 1, 0, 0, NOW() - INTERVAL 10 DAY, NOW()),
    ('CABLE-ORGANISER-01', 'PAS004IBAM', 1, 0, 0, NOW() - INTERVAL 15 DAY, NOW()),
    ('FIBRE-OPTIC-01',     'PAS005IBAM', 1, 0, 0, NOW() - INTERVAL 20 DAY, NOW());

-- ============================================================
--  Vérification des insertions
-- ============================================================
SELECT '=== RÉSUMÉ DES DONNÉES INSÉRÉES ===' AS 'Message';

SELECT 'Tickets'              AS 'Catégorie', COUNT(*) AS 'Nombre'
    FROM glpi_tickets
    WHERE date_creation >= NOW() - INTERVAL 31 DAY
UNION ALL
SELECT 'Ordinateurs',         COUNT(*) FROM glpi_computers          WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Moniteurs',           COUNT(*) FROM glpi_monitors            WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Périphériques',       COUNT(*) FROM glpi_peripherals         WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Équipements réseau',  COUNT(*) FROM glpi_networkequipments   WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Imprimantes',         COUNT(*) FROM glpi_printers            WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Téléphones',          COUNT(*) FROM glpi_phones              WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'Logiciels',           COUNT(*) FROM glpi_softwares           WHERE entities_id = 1
UNION ALL
SELECT 'Licences',            COUNT(*) FROM glpi_softwarelicenses    WHERE entities_id = 1
UNION ALL
SELECT 'Baies',               COUNT(*) FROM glpi_racks               WHERE entities_id = 1
UNION ALL
SELECT 'Châssis',             COUNT(*) FROM glpi_enclosures          WHERE name LIKE '%IBAM%'
UNION ALL
SELECT 'PDU',                 COUNT(*) FROM glpi_pdus                WHERE entities_id = 1
UNION ALL
SELECT 'Équipements passifs', COUNT(*) FROM glpi_passivedcequipments WHERE name LIKE '%IBAM%';

-- ============================================================
--  Fin du script
-- ============================================================