<?php
$root = "../";
$idDresseur = $_GET["id"];

// Si aucun id n'est donné, ne rien faire
if ($idDresseur == "")
{
  echo "Missing id Dresseur";
  return;
}

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// Sélectionne les pokémons du dresseur
$pokemonsQuery = $pdo->prepare("SELECT  Pokemon.id, Pokemon.numero,
                                Pokedex.espece, Pokedex.image AS pokedex_image
                                FROM Pokemon
                                INNER JOIN Pokedex ON Pokedex.numero = Pokemon.numero
                                WHERE Pokemon.idDresseur = ?");
$pokemonsQuery->execute([$idDresseur]);
$pokemons = $pokemonsQuery->fetchAll();

// Récupère le nom du dresseur
$dresseurQuery = $pdo->prepare("SELECT nom FROM Dresseur WHERE id = ?");
$dresseurQuery->execute([$idDresseur]);
$dresseur = $dresseurQuery->fetch();

$dresseurNom = $dresseur["nom"];

// HTML pour l'header
$headingContent =
"<div class='heading'>
  <h2>Pokémons de $dresseurNom</h2>
</div>";

// Génération de l'HTML pour les pokémons du dresseur sélectionné
$pokemonsHtml = "<div class='row centered'>";

foreach ($pokemons as $pokemon) {
  // Déclarer les variables PHP avec les infos
  $pokemonId = $pokemon["id"];
  $pokemonNumero = $pokemon["numero"];
  $pokemonEspece = $pokemon["espece"];
  $pokemonImage = $pokemon["pokedex_image"];

  // Affichage
  $pokemonsHtml .= "<div class='col-md-6 col-lg-4'>
                      <div class='cardpokemons border-0'><a class='function' href='/combat/combat.php?idPlayer=$pokemonId'><img src='$root$pokemonImage' alt='Image de $pokemonImage' class='pokemonsimage card-img-top pokemonsimage scale-on-hover'></a>
                        <div class='card-body'>
                          <h6><a class='function' href='/combat/combat.php?idPlayer=$pokemonId'>$pokemonEspece</a></h6>
                        </div>
                      </div>
                    </div>";
}

$pokemonsHtml .= "</div>";

header('Content-Type: text/html');

echo $headingContent . $pokemonsHtml;
