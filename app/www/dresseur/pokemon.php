<?php
// Path to root
$root = "../";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// id
$id = $_GET["id"];

// Récupérer le Pokémon
$pokemonQuery = $pdo->prepare("SELECT * FROM Pokemon INNER JOIN pokedex ON Pokedex.numero = Pokemon.numero WHERE Pokemon.id = ?");
$pokemonQuery->execute([$id]);
$pokemon = $pokemonQuery->fetch();

// Déclarer les variables PHP avec les infos
$pokemonSexe = ucfirst(mb_strtolower($pokemon["sexe"]));
$pokemonNumero = $pokemon["numero"];
$pokemonEspece = $pokemon["espece"];
$pokemonImage = $pokemon["image"];
$pokemonShiny = $pokemon["shiny"];
$pokemonIdDresseur = $pokemon["iddresseur"];

// Récupérer le Dresseur du Pokémon
$pokemonDresseurQuery = $pdo->prepare("SELECT * FROM Dresseur WHERE Dresseur.id = ?");
$pokemonDresseurQuery->execute([$pokemonIdDresseur]);
$pokemonDresseur = $pokemonDresseurQuery->fetch();
$pokemonDresseurNom = $pokemonDresseur["nom"];

// Récupérer les types du Pokémon
$typesQuery = $pdo->prepare("SELECT * FROM typepokedex WHERE numeroPokedex = ?");
$typesQuery->execute([$pokemonNumero]);
$typesReply = $typesQuery->fetchAll();

$types = $array = ["Type1" => "", "Type2" => ""];
foreach ($typesReply as $type) {
  array_push($types, $type["nomtypeelementaire"]);
}

// Récupérer ses capacités
$capacitesQuery = $pdo->prepare("SELECT * FROM PokemonCapacite INNER JOIN Capacite ON Capacite.nom = PokemonCapacite.nomCapacite WHERE PokemonCapacite.idPokemon = ?");
$capacitesQuery->execute([$id]);
$capacites = $capacitesQuery->fetchAll();
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokémon - <?= $pokemonEspece ?></title>
  <link rel="stylesheet" href="<?= $root?>assets/bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:300,400,700">
  <link rel="stylesheet" href="<?= $root?>assets/fonts/ionicons.min.css">
</head>

<body>
  <?php
  include $root . 'navBar.php';
  ?>
  <main class="page project-page">
    <section class="portfolio-block project">
      <div>
        <div class="pokemonheading">
          <h2><?= $pokemonEspece . ($pokemonShiny ? " Shiny" : "") ?></h2>
        </div>
        <div class="heading">
          <?php
          print_r("<img class='pokemonbig' src='$root$pokemonImage'>");
          ?>
        </div>
        <div class="blocinfos">
          <div class="colonneinfos">
            <h3>Infos</h3>
            <p>Sexe: <?= $pokemonSexe ?></p>
            <p>Numero Pokedex : <?= $pokemonNumero ?></p>
            <p>Dresseur : <?= $pokemonDresseurNom ?></p>
            <p><?= $pokemonShiny ? "" : "Pas " ?> Shiny</p>
            <p>________________</p>
            <p><b>Type<?= $types[1] ? "s" : "" ?></b></p>
            <?php
            $types[0] ? print_r("<p class='Color$types[0]'>$types[0]</p>") : "";
            $types[1] ? print_r("<p class='Color$types[1]'>$types[1]</p>") : "";
            ?>
          </div>
        </div>
      </div>
    </section>
  </main>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Capacités de <?= $pokemonEspece ?></h2>
        </div>
        <div class="row centered">
        <?php
          foreach ($capacites as $capacite) {
            $capaciteNom = $capacite["nom"];
            $capaciteStatut = $capacite["statut"];
            $capacitePuissance = $capacite["puissance"];
            $capacitePP = $capacite["pp"];
            $capacitePrecision = $capacite["precision"];
            $capaciteEffetSecondaire = $effetsSecondaires[$capaciteNom];
            $capaciteNomType = $capacite["nomtype"];

            if (!$capaciteEffetSecondaire)
              $capaciteEffetSecondaire = "aucun";

            print_r("<div class='col-md-6 col-lg-4'>
              <div class='cardcapacites $capaciteNomType'>
                <div class='card-body'>
                  <h6>$capaciteNom</h6>
                  <p class='text-muted card-text'>Statut: $capaciteStatut</p>
                  <p class='text-muted card-text'>Puissance: $capacitePuissance</p>
                  <p class='text-muted card-text'>PP: $capacitePP</p>
                  <p class='text-muted card-text'>Precision: $capacitePrecision</p>
                  <p class='text-muted card-text'>Effet secondaire: $capaciteEffetSecondaire</p>
                  <p class='Color$capaciteNomType card-text'>Type: $capaciteNomType</p>
                </div>
              </div>
            </div>");
          }
          ?>
        </div>
      </div>
    </section>
  </main>
  <?php
  include $root . 'footer.php';
  ?>
  <script src="<?= $root?>assets/js/jquery.min.js"></script>
  <script src="<?= $root?>assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="<?= $root?>assets/js/theme.js"></script>
</body>

</html>
