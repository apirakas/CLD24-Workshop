<?php
// Path to root
$root = "./";
$id = $_GET["id"];

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// Récupérer le Dresseur
$dresseurQuery = $pdo->prepare("SELECT * FROM dresseur WHERE id = ?");
$dresseurQuery->execute([$id]);
$dresseur = $dresseurQuery->fetch();


// Déclarer les variables PHP avec les infos
$dresseurNom = $dresseur["nom"];
$dresseurId = $dresseur["id"];
$dresseurLieu = $dresseur["idlieu"];
$dresseurType = ucfirst(mb_strtolower($dresseur["type"]));
$dresseurImage = $dresseur["image"];
$dresseurSexe = $dresseur["sexe"];

if ($dresseurSexe == "MÂLE") {
  $sexe = "Homme";
} else if ($dresseurSexe == "FEMELLE") {
  $sexe = "Femme";
} else {
  $sexe = "Asexué";
}

// Récupérer les Pokémon du dresseur
$pokemonsQuery = $pdo->prepare("SELECT * FROM Pokemon INNER JOIN Pokedex ON pokemon.numero = pokedex.numero WHERE idDresseur = ?");
$pokemonsQuery->execute([$id]);
$pokemons = $pokemonsQuery->fetchAll();
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dresseur - <?= $dresseurNom ?></title>
  <link rel="stylesheet" href="<?= $root ?>assets/bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:300,400,700">
  <link rel="stylesheet" href="<?= $root ?>assets/fonts/ionicons.min.css">
</head>

<body>
  <?php
  include $root . 'navBar.php';
  ?>
  <main class="page project-page">
    <section class="portfolio-block project">
      <div>
        <div class="dresseurheading">
          <h2><?= $dresseurNom ?></h2>
        </div>
        <div class="heading">
          <?php
          print_r("<img class='dresseurbig' src='$root$dresseurImage'>");
          ?>
        </div>
        <div class="blocinfos">
          <div class="colonneinfos">
            <h3>Infos</h3>
            <p>Nom : <?= $dresseurNom ?></p>
            <p>Catégorie : <?= $dresseurType ?></p>
            <p>Sexe : <?= $sexe ?></p>
          </div>
        </div>
      </div>
    </section>
  </main>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Pokémons de <?= $dresseurNom ?></h2>
        </div>
        <div class="row centered">
          <?php
          foreach ($pokemons as $pokemon) {
            $pokemonEspece = $pokemon["espece"];
            $pokemonImage = $pokemon["image"];
            $pokemonNumero = $pokemon["numero"];
            $pokemonId = $pokemon["id"];
            $pokemonPoids = $pokemon["poids"];
            $pokemonTaille = $pokemon["taille"];
            $pokemonSex = $pokemon["sexe"];
            print_r(" <div class='col-md-6 col-lg-4'>
                            <div class='cardpokemons border-0'><a href='/dresseur/pokemon.php?id=$pokemonId'><img src='$root$pokemonImage' alt='Image de $pokemonImage' class='pokemonsimage card-img-top pokemonsimage scale-on-hover'></a>
                              <div class='card-body'>
                                <h6><a href='/dresseur/pokemon.php?id=$pokemonId'>$pokemonEspece</a></h6>
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
  <script src="<?= $root ?>assets/js/jquery.min.js"></script>
  <script src="<?= $root ?>assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="<?= $root ?>assets/js/theme.js"></script>
</body>

</html>
