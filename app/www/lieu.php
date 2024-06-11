<?php
// Path to root
$root = "./";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");

// Récupérer le lieu
$lieuQuery = $pdo->query("SELECT * FROM lieu WHERE id = $_GET[id]");
$lieuQuery->execute(array());
$lieuReply = $lieuQuery->fetchAll();

foreach ($lieuReply as $lieu) {
  // Déclarer les variables PHP avec les infos
  $lieuID = $lieu["id"];
  $lieuNom = $lieu["nom"];
  $lieuType = $lieu["nomtypelieu"];
  $lieuImage = $lieu["image"];
}
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lieu - <?= $lieuNom ?></title>
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
        <div class="lieuheading">
          <h2><?= $lieuNom ?></h2>
        </div>
        <div class="heading">
          <?php
          print_r("<img class='lieubig' src='$root$lieuImage'>");
          ?>
        </div>
        <div class="blocinfos">
          <div class="colonneinfos">
            <h3>Infos</h3>
            <p><?= $lieuType ?> du nom de <?= $lieuNom ?></p>
          </div>
        </div>
      </div>
    </section>
  </main>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Espèces vivant dans le type de lieu <?= $lieuType ?></h2>
        </div>
        <div class="row centered">
          <?php
          // Récupérer les Pokémons
          $pokemonsQuery = $pdo->query("SELECT * FROM pokedex
                                                  INNER JOIN pokedexlieu ON pokedex.numero = pokedexlieu.numeropokedex
                                                  WHERE pokedexlieu.nomTypelieu = '$lieuType'
                                                  ORDER BY numero");
          $pokemonsQuery->execute(array());
          $pokemonsReply = $pokemonsQuery->fetchAll();

          // Pour chaque entrée...
          foreach ($pokemonsReply as $pokemon) {
            // Déclarer les variables PHP avec les infos
            $pokemonNumero = $pokemon["numero"];
            $pokemonEspece = $pokemon["espece"];
            $pokemonLegendaire = $pokemon["legendaire"];
            $pokemonTaille = $pokemon["taille"];
            $pokemonPoids = $pokemon["poids"];
            $pokemonImage = $pokemon["image"];

            // Affichage
            print_r("<div class='col-md-6 col-lg-4'>
                                <div class='cardpokemons border-0'><a href='/pokedex/pokemon.php?id=$pokemonNumero'><img src='$root$pokemonImage' alt='Image de $pokemonImage' class='pokemonsimage card-img-top pokemonsimage scale-on-hover'></a>
                                  <div class='card-body'>
                                    <h6><a href='/pokedex/pokemon.php?id=$pokemonNumero'>$pokemonEspece</a></h6>
                                    <p class='text-muted card-text'>#$pokemonNumero - $pokemonTaille m - $pokemonPoids kg</p>
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
          <h2>Dresseurs de <?= $lieuNom ?></h2>
        </div>
        <div class="row centered">
          <?php
          // Récupérer les dresseurs
          $dresseursQuery = $pdo->query("SELECT * FROM dresseur
                                                   WHERE dresseur.idlieu = '$lieuID'
                                                   ORDER BY dresseur.nom");
          $dresseursQuery->execute(array());
          $dresseursReply = $dresseursQuery->fetchAll();

          // Pour chaque entrée...
          foreach ($dresseursReply as $dresseur) {
            // Déclarer les variables PHP avec les infos
            $dresseurId = $dresseur["id"];
            $dresseurNom = $dresseur["nom"];
            $dresseurType = ucfirst(strtolower($dresseur["type"]));
            $dresseurImage = $dresseur["image"];

            // Affichage
            print_r("<div class='col-md-6 col-lg-4'>
                                   <div class='carddresseurs border-0'><a href='dresseur.php?id=$dresseurId'><img src='$root$dresseurImage' alt='Image de $dresseurNom' class='dresseursimage card-img-top dresseursimage scale-on-hover'></a>
                                     <div class='card-body'>
                                       <h6><a href='dresseur.php?id=$dresseurId'>$dresseurNom</a></h6>
                                       <p class='text-muted card-text'>$dresseurType</p>
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