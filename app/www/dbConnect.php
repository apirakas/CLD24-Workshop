<?php
$host = 'db'; // Le nom du service du conteneur de la base de données dans Docker Compose
$port = '5432'; // Le port exposé dans le conteneur Docker
$dbname = 'workshopCLD'; // Le nom de la base de données
$user = 'postgres'; // Le username
$password = 'trustno1'; // Le mot de passe

try {
  // Connexion à la base de données
  $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;user=$user;password=$password";
  $pdo = new PDO($dsn);

  // Configurer PDO pour afficher les erreurs
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
// Récupérer l'erreur si il y a un problème de connexion à la base de données
catch (Exception $e) {
  // Afficher l'erreur
  print_r($e);
}
