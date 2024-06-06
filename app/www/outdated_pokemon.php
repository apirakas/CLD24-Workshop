<?php
// Path to root
$root = "./";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// Récupérer le Pokémon
$pokemonQuery = $pdo->query("SELECT * FROM pokedex WHERE numero = $_GET[id]");
$pokemonQuery->execute(array());
$pokemonReply = $pokemonQuery->fetchAll();

foreach ($pokemonReply as $pokemon) {
  // Déclarer les variables PHP avec les infos
  $pokemonNumero = $pokemon["numero"];
  $pokemonEspece = $pokemon["espece"];
  $pokemonTaille = $pokemon["taille"];
  $pokemonPoids = $pokemon["poids"];
  $pokemonPV = $pokemon["pv"];
  $pokemonAttaque = $pokemon["attaque"];
  $pokemonDefense = $pokemon["defense"];
  $pokemonAttaqueSpeciale = $pokemon["attaquespeciale"];
  $pokemonDefenseSpeciale = $pokemon["defensespeciale"];
  $pokemonVitesse = $pokemon["vitesse"];
  $pokemonImage = $pokemon["image"];

  // Légendaire ?
  if ($pokemon["legendaire"] == TRUE) {
    $pokemonLegendaire = "Oui";
  } else if ($pokemon["legendaire"] == FALSE) {
    $pokemonLegendaire = "Non";
  }

  // Couleur d'affichage des stats
  $couleurPV = floor($pokemonPV / 12);
  if ($couleurPV > 10) {
    $couleurPV = 10;
  }
  $couleurAttaque = floor($pokemonAttaque / 12);
  if ($couleurAttaque > 10) {
    $couleurAttaque = 10;
  }
  $couleurDefense = floor($pokemonDefense / 12);
  if ($couleurDefense > 10) {
    $couleurDefense = 10;
  }
  $couleurAttaqueSpeciale = floor($pokemonAttaqueSpeciale / 12);
  if ($couleurAttaqueSpeciale > 10) {
    $couleurAttaqueSpeciale = 10;
  }
  $couleurDefenseSpeciale = floor($pokemonDefenseSpeciale / 12);
  if ($couleurDefenseSpeciale > 10) {
    $couleurDefenseSpeciale = 10;
  }
  $couleurVitesse = floor($pokemonVitesse / 12);
  if ($couleurVitesse > 10) {
    $couleurVitesse = 10;
  }

  // Récupérer les types du Pokémon
  $typesQuery = $pdo->query("SELECT * FROM typepokedex WHERE numeropokedex = $_GET[id]");
  $typesQuery->execute(array());
  $typesReply = $typesQuery->fetchAll();

  $types = $array = ["Type1" => "", "Type2" => ""];
  foreach ($typesReply as $type) {
    array_push($types, $type["nomtypeelementaire"]);
  }

  // Récupérer les évolutions du Pokémon
  // TODO

  // Récupérer ses attaques possible
  // TODO

  // Récupérer les lieux où il vit
  // TODO
}
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokémon - <?= $pokemonEspece ?></title>
  <link rel="stylesheet" href="../assets/bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:300,400,700">
  <link rel="stylesheet" href="../assets/fonts/ionicons.min.css">
</head>

<body>
  <?php
  include 'navBar.php';
  ?>
  <main class="page project-page">
    <section class="portfolio-block project">
      <div>
        <div class="pokemonheading">
          <h2><?= $pokemonEspece ?></h2>
        </div>
        <div class="heading">
          <?php
          print_r("<img class='pokemonbig' src='$pokemonImage'>");
          ?>
        </div>
        <div class="blocinfos">
          <div class="colonneinfos">
            <h3>Infos</h3>
            <p>Nom : <?= $pokemonEspece ?></p>
            <p>Légendaire : <?= $pokemonLegendaire ?></p>
            <p>________________</p>
            <p>Taille : <?= $pokemonTaille ?>m</p>
            <p>Poids : <?= $pokemonPoids ?>kg</p>
            <p>________________</p>
            <p><b>Types</b></p>
            <?php
            print_r("<p class='Color$types[0]'>$types[0]</p>");
            print_r("<p class='Color$types[1]'>$types[1]</p>");
            ?>
          </div>
          <div class="colonneinfos">
            <h3>Statistiques</h3>
            <?php
            print_r("<p class='Color$couleurPV''>PV : $pokemonPV</p>");
            print_r("<p class='Color$couleurAttaque''>Attaque : $pokemonAttaque</p>");
            print_r("<p class='Color$couleurDefense''>Défense : $pokemonDefense</p>");
            print_r("<p class='Color$couleurAttaqueSpeciale''>Attaque spéciale : $pokemonAttaqueSpeciale</p>");
            print_r("<p class='Color$couleurDefenseSpeciale''>Défense spéciale : $pokemonDefenseSpeciale</p>");
            print_r("<p class='Color$couleurVitesse''>Vitesse : $pokemonVitesse</p>");
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
          <h2>Évolutions de <?= $pokemonEspece ?></h2>
        </div>
        <div class="row">
        </div>
      </div>
    </section>
  </main>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Attaques de <?= $pokemonEspece ?></h2>
        </div>
        <div class="row">
        </div>
      </div>
    </section>
  </main>
  <?php
  include 'footer.php';
  ?>
  <script src="assets/js/jquery.min.js"></script>
  <script src="assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="assets/js/theme.js"></script>
</body>

</html>