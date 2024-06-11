<?php
$host = 'localhost'; // Utilisez localhost si la DB est sur la même VM
$port = '5432'; // Le port par défaut pour PostgreSQL
$dbname = 'workshopcld'; // Le nom de la base de données
$user = 'postgres'; // Le username
$password = 'trustno1'; // Le mot de passe

try {
  // Connexion à la base de données
  $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;user=$user;password=$password";
  $pdo = new PDO($dsn);

  // Configurer PDO pour afficher les erreurs
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
// Récupérer l'erreur s'il y a un problème de connexion à la base de données
catch (Exception $e) {
  // Afficher l'erreur
  echo "Erreur de connexion à la base de données: " . $e->getMessage();
}
