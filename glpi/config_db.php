<?php
/**
 * TP Final — Intégration Logicielle — M2 ISIE IBAM / UJKZ
 * Groupe 6 :
 *   - KOURAOGO W Joel Faïsal
 *   - PARE Kontama Léandre Bénilde
 *   - COULIBALY Abdoul Rachid
 *
 * Fichier de configuration de la connexion GLPI à MariaDB.
 * Ce fichier est généré automatiquement par le wizard d'installation GLPI.
 * Il est fourni ici à titre documentaire (optionnel selon le sujet).
 *
 * IMPORTANT : Ne pas commiter ce fichier avec de vrais mots de passe.
 * Les valeurs sensibles doivent être gérées via le fichier .env
 */

class DB extends DBmysql {

    /** @var string Hôte du serveur MariaDB (nom du service Docker) */
    public $dbhost = 'mariadb';

    /** @var string Nom de la base de données GLPI */
    public $dbdefault = 'glpi';

    /** @var string Utilisateur MariaDB */
    public $dbuser = 'glpi_user';

    /** @var string Mot de passe MariaDB (à définir via .env en production) */
    public $dbpassword = 'glpi_pass_2024';

    /** @var bool Utiliser le mode de compatibilité strict */
    public $use_utf8mb4 = true;

    /** @var bool Activer le log des requêtes SQL (désactiver en production) */
    public $allow_myisam = false;

    /** @var bool Autoriser les datetime sans timezone */
    public $allow_datetime = false;

    /** @var bool Autoriser les valeurs NULL dans les clés étrangères */
    public $allow_signed_keys = false;
}
