<?php
// Path to root
$root = "../";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// id
$id = $_GET["id"];

// Récupérer le Pokémon
$pokemonQuery = $pdo->prepare("SELECT * FROM pokedex WHERE numero = ?");
$pokemonQuery->execute([$id]);
$pokemon = $pokemonQuery->fetch();

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
$typesQuery = $pdo->query("SELECT * FROM typepokedex WHERE numeropokedex = $id");
$typesQuery->execute(array());
$typesReply = $typesQuery->fetchAll();

$types = $array = ["Type1" => "", "Type2" => ""];
foreach ($typesReply as $type) {
  array_push($types, $type["nomtypeelementaire"]);
}


// Récupérer les évolutions du Pokémon
$evolutions = [$pokemon];
$currentId = $id;
$nextEvolutionQuery = $pdo->prepare("SELECT * FROM Pokedex WHERE numero = (SELECT evolution FROM EvolutionPokedex WHERE base = ?)");

// On cherche les évolutions autour du pokemon, commençant par lui <--id-->

// Ajoute toutes les prochaines évolutions à la fin de la liste (dans l'ordre)
while ($currentId) {
  $nextEvolutionQuery->execute([$currentId]);
  $nextEvolutionReply = $nextEvolutionQuery->fetch();

  if ($nextEvolutionReply) {
    array_push($evolutions, $nextEvolutionReply);
    $currentId = $nextEvolutionReply["numero"];
  } else {
    $currentId = null; // Break the loop if no more evolutions are found
  }
}

$currentId = $id;
$lastEvolutionQuery = $pdo->prepare("SELECT * FROM Pokedex WHERE numero = (SELECT base FROM EvolutionPokedex WHERE evolution = ?)");

// Ajoute toutes les précédentes évolutions au début de la liste (dans l'ordre)
while ($currentId) {
  $lastEvolutionQuery->execute([$currentId]);
  $lastEvolutionReply = $lastEvolutionQuery->fetch();

  if ($lastEvolutionReply) {
    array_unshift($evolutions, $lastEvolutionReply);
    $currentId = $lastEvolutionReply["numero"];
  } else {
    $currentId = null; // Break the loop if no more evolutions are found
  }
}


// Récupérer ses capacités possible
$capacitesQuery = $pdo->prepare("SELECT * FROM Capacite WHERE Capacite.nom IN (SELECT nomCapacite FROM PokedexCapacitePool WHERE numeroPokedex = ?)");
$capacitesQuery->execute([$id]);
$capacites = $capacitesQuery->fetchAll();

$effetsSecondaires = [];
$effetsSecondairesQuery = $pdo->prepare("SELECT effet FROM EffetSecondaire WHERE EffetSecondaire.id = ?");

foreach($capacites as $capacite) {
  $capaciteIdEffetSecondaire = $capacite["ideffetsecondaire"];
  if ($capaciteIdEffetSecondaire) {
    $effetsSecondairesQuery->execute([$capaciteIdEffetSecondaire]);
    $effetSecondaire = $effetsSecondairesQuery->fetch();
    $effetsSecondaires[$capacite["nom"]] = $effetSecondaire["effet"];
  }
}

// Récupérer les lieux où il vit
$lieuxQuery = $pdo->prepare("SELECT * FROM Lieu WHERE Lieu.nomTypeLieu IN (SELECT PokedexLieu.nomTypeLieu FROM PokedexLieu WHERE PokedexLieu.numeroPokedex = ?)");
$lieuxQuery->execute([$id]);
$lieux = $lieuxQuery->fetchAll();
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
          <h2><?= $pokemonEspece ?></h2>
        </div>
        <div class="heading">
          <?php
          print_r("<img class='pokemonbig' src='$root$pokemonImage'>");
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
        <div class="row centered">
          <?php
          foreach ($evolutions as $evolution) {
            $evolutionNumero = $evolution["numero"];
            $evolutionImage = $evolution["image"];
            $evolutionEspece = $evolution["espece"];
            $evolutionTaille = $evolution["taille"];
            $evolutionPoids = $evolution["poids"];

            print_r("<div class='col-md-6 col-lg-4'>
              <div class='cardpokemons border-0'><a href='pokemon.php?id=$evolutionNumero'><img src='$root$evolutionImage' alt='Image de $evolutionImage' class='pokemonsimage card-img-top pokemonsimage scale-on-hover'></a>
                <div class='card-body'>
                  <h6><a href='pokemon.php?id=$evolutionNumero'>$evolutionEspece</a></h6>
                  <p class='text-muted card-text'>#$evolutionNumero - $evolutionTaille m - $evolutionPoids kg</p>
                </div>
              </div>
            </div>");
          }
          ?>
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
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Lieux de vie dans la nature de <?= $pokemonEspece ?></h2>
        </div>
        <div class="row centered">
          <?php
          foreach($lieux as $lieu) {
            $lieuID = $lieu["id"];
            $lieuNom = $lieu["nom"];
            $lieuType = $lieu["nomtypelieu"];
            $lieuImage = $lieu["image"];

            // Affichage
            print_r("<div class='col-md-6 col-lg-4'>
                      <div class='cardlieux border-0'><a href='/lieu.php?id=$lieuID'><img src='$root$lieuImage' alt='Image de $lieuNom' class='lieuximage card-img-top lieuximage scale-on-hover'></a>
                        <div class='card-body'>
                          <h6><a href='/lieu.php?id=$lieuID'>$lieuNom</a></h6>
                          <p class='text-muted card-text'>$lieuType</p>
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
