<?php
// Path to root
$root = "../";

// Get ids
$idPlayer = $_GET["idPlayer"];
$idOpponent = $_GET["idOpponent"];

if (!$idPlayer) {
  echo "Missing id of Player's Pokemon";
  return;
}

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");


// Sélectionne le pokémon choisi
$playerQuery = $pdo->prepare("SELECT  Pokemon.id AS pokemon_id,
                                      Pokedex.numero AS pokedex_numero,
                                      Pokedex.espece AS pokedex_espece,
                                      Pokedex.PV AS pokedex_PV,
                                      Pokedex.attaque AS pokedex_attaque,
                                      Pokedex.defense AS pokedex_defense,
                                      Pokedex.attaqueSpeciale AS pokedex_attaqueSpeciale,
                                      Pokedex.defenseSpeciale AS pokedex_defenseSpeciale,
                                      Pokedex.vitesse AS pokedex_vitesse,
                                      Pokedex.image AS pokedex_image,
                                      Dresseur.id AS dresseur_id,
                                      Dresseur.nom AS dresseur_nom,
                                      Dresseur.image AS dresseur_image
                              FROM Pokemon
                              INNER JOIN Pokedex ON Pokedex.numero = Pokemon.numero
                              INNER JOIN Dresseur ON Pokemon.idDresseur = Dresseur.id
                              WHERE Pokemon.id = ?");
$playerQuery->execute([$idPlayer]);
$player = $playerQuery->fetch(PDO::FETCH_ASSOC);

// Si aucun pokémon adverse choisi, choisir aléatoirement
if (!$idOpponent) {
  $playerIdDresseur = $player["dresseur_id"];
  // Sélectionne les pokémons possibles (Tous sauf ceux du même dresseur)
  $pokemonsIdPoolQuery = $pdo->prepare("SELECT Pokemon.id
                                        FROM Pokemon
                                        WHERE Pokemon.idDresseur != ?");
  $pokemonsIdPoolQuery->execute([$playerIdDresseur]);
  $pokemonsId = $pokemonsIdPoolQuery->fetchAll(PDO::FETCH_ASSOC);
  // Double random pour plus d'aléatoire
  shuffle($pokemonsId);
  $idOpponent = $pokemonsId[random_int(0, count($pokemonsId) - 1)]["id"];
}

$opponentQuery = $pdo->prepare("SELECT  Pokemon.id AS pokemon_id,
                                        Pokedex.numero AS pokedex_numero,
                                        Pokedex.espece AS pokedex_espece,
                                        Pokedex.PV AS pokedex_PV,
                                        Pokedex.attaque AS pokedex_attaque,
                                        Pokedex.defense AS pokedex_defense,
                                        Pokedex.attaqueSpeciale AS pokedex_attaqueSpeciale,
                                        Pokedex.defenseSpeciale AS pokedex_defenseSpeciale,
                                        Pokedex.vitesse AS pokedex_vitesse,
                                        Pokedex.image AS pokedex_image,
                                        Dresseur.id AS dresseur_id,
                                        Dresseur.nom AS dresseur_nom,
                                        Dresseur.image AS dresseur_image
                                FROM Pokemon
                                INNER JOIN Pokedex ON Pokedex.numero = Pokemon.numero
                                INNER JOIN Dresseur ON Pokemon.idDresseur = Dresseur.id
                                WHERE Pokemon.id = ?");
$opponentQuery->execute([$idOpponent]);
$opponent = $opponentQuery->fetch(PDO::FETCH_ASSOC);

$playerCapacities = $pdo->prepare(" SELECT Capacite.nom AS capacite_nom, Capacite.nomType AS capacite_type
                                    FROM PokemonCapacite
                                    INNER JOIN Capacite ON Capacite.nom = PokemonCapacite.nomCapacite
                                    WHERE PokemonCapacite.idPokemon = ?");
$playerCapacities->execute([$idPlayer]);
$playerCapacities = $playerCapacities->fetchAll(PDO::FETCH_ASSOC);
?>

<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokédex - Combat</title>
  <link rel="stylesheet" href="<?= $root ?>assets/bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="<?= $root ?>assets/css/combat.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:300,400,700">
  <link rel="stylesheet" href="<?= $root ?>assets/fonts/ionicons.min.css">
</head>

<body>
  <?php
  include $root . 'navBar.php';
  ?>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="combat grid" id="selection">
        <?php
        // Dresseur du joueur
        $playerDresseurImage = $player['dresseur_image'];
        $playerDresseurNom = $player['dresseur_nom'];
        print_r(" <div class='combat dresseur player'>
          <img src='$root$playerDresseurImage' alt='Image de $playerDresseurNom'>
          <h2 style='text-align: center;'>$playerDresseurNom</h2>
          </div>");

        // Pokemon du joueur
        $playerPokedexEspece = $player["pokedex_espece"];
        $playerPokedexImage = $player["pokedex_image"];
        $playerPokemonId = $player["pokemon_id"];
        print_r(" <div class='combat pokemon player' id='$playerPokemonId'>
                    <img src='$root$playerPokedexImage' alt='Image de $playerPokedexEspece'>
                    <div id='player-health-bar' class='health-bar inner'></div>
                    <div class='health-bar border'></div>
                    <p id='player-hp'></p>
                  </div>");

        // Pokemon de l'adversaire
        $opponentPokedexEspece = $opponent["pokedex_espece"];
        $opponentPokedexImage = $opponent["pokedex_image"];
        $opponentPokemonId = $opponent["pokemon_id"];
        print_r(" <div class='combat pokemon opponent' id='$opponentPokemonId'>
                    <img src='$root$opponentPokedexImage' alt='Image de $opponentPokedexEspece'>
                    <div id='opponent-health-bar' class='health-bar inner'></div>
                    <div class='health-bar border'></div>
                    <p id='opponent-hp'></p>
                  </div>");

        // Dresseur adverse
        $opponentDresseurImage = $opponent['dresseur_image'];
        $opponentDresseurNom = $opponent['dresseur_nom'];
        print_r(" <div class='combat dresseur opponent'>
                    <img src='$root$opponentDresseurImage' alt='Image de $opponentDresseurNom'>
                    <h2 style='text-align: center;'>$opponentDresseurNom</h2>
                  </div>");
        ?>
        <div class="combat output">
          <p id='output'></p>
        </div>
      </div>
    </section>
    <!-- modal -->
    <div class="modal fade" id="capacities" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-capacities">
            <?php
            $numberOfCapacityBoxes = 4;

            for ($index = 0; $index < $numberOfCapacityBoxes; $index++) {
              // Check if there is a corresponding capacity for the current index
              if (isset($playerCapacities[$index])) {
                $playerCapacityType = ($playerCapacities[$index]["capacite_type"]);
                $playerCapacityName = $playerCapacities[$index]["capacite_nom"];
              } else {
                $playerCapacityType = "";
                $playerCapacityName = "";
              }
              print_r(" <div class='modal-capacity cardcapacites function $playerCapacityType' id='capacity-$index'>
                          <p style='margin-top: 1rem;'>$playerCapacityName</p>
                        </div>");
            }
            ?>
          </div>
        </div>                                                                       
      </div>                                          
    </div>
  </main>
  <script src="<?= $root ?>assets/js/jquery.min.js"></script>
  <script src="<?= $root ?>assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="<?= $root ?>assets/js/theme.js"></script>
  <script src="<?= $root ?>assets/js/combat/combat.js"></script>
</body>

</html>