<?php
// Path to root
$root = "./";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokédex - Pokédex</title>
  <link rel="stylesheet" href="<?= $root?>assets/bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Lato:300,400,700">
  <link rel="stylesheet" href="<?= $root?>assets/fonts/ionicons.min.css">
</head>

<body>
  <?php
  include $root . 'navBar.php';
  ?>
  <main class="page projects-page">
    <section class="portfolio-block projects-cards">
      <div class="container">
        <div class="heading">
          <h2>Pokédex</h2>
        </div>
        <div class="row">
          <?php
          // Récupérer les Pokémons
          $pokemonsQuery = $pdo->query("SELECT * FROM pokedex ORDER BY numero");
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
            $pokemonPV = $pokemon["pv"];
            $pokemonAttaque = $pokemon["attaque"];
            $pokemonDefense = $pokemon["defense"];
            $pokemonAttaqueSpeciale = $pokemon["attaquespeciale"];
            $pokemonDefenseSpeciale = $pokemon["defensespeciale"];
            $pokemonVitesse = $pokemon["vitesse"];
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
  <?php
  include $root . 'footer.php';
  ?>
  <script src="<?= $root?>assets/js/jquery.min.js"></script>
  <script src="<?= $root?>assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="<?= $root?>assets/js/theme.js"></script>
</body>

</html>