<?php
// Path to root
$root = "../";

// Get ids
$idPlayer = $_GET["idPlayer"];
$idOpponent = $_GET["idOpponent"];

if (!$idPlayer || !$idOpponent)
{
  echo "Missing id's";
  return;
}

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");


// Récupération des stats des pokémons concernés
$statsQuery = $pdo->prepare("SELECT Pokemon.id,
                                    Pokedex.espece,
                                    Pokedex.PV,
                                    Pokedex.attaque,
                                    Pokedex.defense,
                                    Pokedex.attaqueSpeciale,
                                    Pokedex.defenseSpeciale,
                                    Pokedex.vitesse
                              FROM Pokemon
                              INNER JOIN Pokedex ON Pokedex.numero = Pokemon.numero
                              WHERE Pokemon.id = ?");
$statsQuery->execute([$idPlayer]);
$player = $statsQuery->fetch(PDO::FETCH_ASSOC);

$statsQuery->execute([$idOpponent]);
$opponent = $statsQuery->fetch(PDO::FETCH_ASSOC);

// Récupération des types des pokémons
$typesQuery = $pdo->prepare(" SELECT TypePokedex.nomTypeElementaire
                              FROM TypePokedex
                              WHERE TypePokedex.numeroPokedex IN (SELECT Pokemon.numero
                                                                  FROM Pokemon
                                                                  WHERE Pokemon.id = ?)");

$typesQuery->execute([$idPlayer]);
$playerTypes = $typesQuery->fetchAll(PDO::FETCH_ASSOC);

$typesQuery->execute([$idOpponent]);
$opponentTypes = $typesQuery->fetchAll(PDO::FETCH_ASSOC);

$player["types"] = [];
foreach ($playerTypes as $type) {
  array_push($player["types"],$type["nomtypeelementaire"]);
}

$opponent["types"] = [];
foreach ($opponentTypes as $type) {
  array_push($opponent["types"],$type["nomtypeelementaire"]);
}

// Récupération des capacités des pokémons
$capaciteQuery = $pdo->prepare("SELECT  Capacite.nom,
                                        Capacite.statut,
                                        Capacite.puissance,
                                        Capacite.PP,
                                        Capacite.precision,
                                        Capacite.nomType AS type,
                                        EffetSecondaire.id AS effetSecondaire_id,
                                        EffetSecondaire.effet AS effetsecondaire
                                  FROM PokemonCapacite
                                  INNER JOIN Capacite ON Capacite.nom = PokemonCapacite.nomCapacite
                                  LEFT JOIN EffetSecondaire ON EffetSecondaire.id = Capacite.idEffetSecondaire
                                  WHERE PokemonCapacite.idPokemon = ?");

$capaciteQuery->execute([$idPlayer]);
$capacitesPlayer = $capaciteQuery->fetchAll(PDO::FETCH_ASSOC);
$player["capacites"] = $capacitesPlayer;

$capaciteQuery->execute([$idOpponent]);
$capacitesOpponent = $capaciteQuery->fetchAll(PDO::FETCH_ASSOC);
$opponent["capacites"] = $capacitesOpponent;

// Récupérer les multiplicateurs
$multsQuery = $pdo->prepare("SELECT * FROM Multiplicateur");
$multsQuery->execute([]);
$multsReply = $multsQuery->fetchAll();

$multiplicateurs;

foreach ($multsReply as $mult) {
  $multSource = $mult["typesource"];
  $multDestination = $mult["typedestination"];
  $multiplicateur = $mult["multiplicateur"];
  // Ordre inversé pour simplification des calculs -> Combat JS
  $multiplicateurs[$multDestination][$multSource] = $multiplicateur;
}

$response = ["player" => $player, "opponent" => $opponent, "multiplicateurs" => $multiplicateurs];

// Encode the data into JSON format with pretty-printing and UTF-8 encoding -> useful for debuging
$jsonResponse = json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

// Set the Content-Type header to application/json
header('Content-Type: application/json; charset=utf-8');

// Output the JSON response
echo $jsonResponse;
