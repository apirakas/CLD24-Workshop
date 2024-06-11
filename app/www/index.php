<?php
// Path to root
$root = "./";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");
?>

<?php
$today = strftime("%d %B %Y");
?>

<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokédex</title>
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
      <div class="container">
        <div class="heading">
          <h2>CLD - Pokédex</h2>
        </div>
        <div class="image" style="background-image:url(&quot;assets/img/pokemonwallpaper.jpg&quot;);"></div>
        <div class="row">
          <div class="col-12 col-md-6 offset-md-1 info">
            <h3>Description</h3>
            <p>Ce site constitue la partie application de notre workshop de CLD (2023 - 2024).</p>
              <p>Il est hébergé sur Azure dans une VM et est loadbalancé par un objet "loadbalancer" offert par Azure. Cette application se connecte à une base de données hébergée par Azure elle aussi.</p>
          </div>
          <div class="col-12 col-md-3 offset-md-1 meta">
            <?php
            print_r("<div class='tags'><span id='auteurlabel'>Auteurs</span><a>Fabrice Chapuis, Nicolas Junod, Anthonponrajkumar Pirakasraj, Richard Aurélien</a><span class='meta-heading'>Date</span><span>$today</span></div>")
            ?>
          </div>
        </div>
        <div class="more-projects">
          <h3 class="text-center">Entrées aléatoires</h3>
          <div class="row gallery">
            <?php
            // Images aléatoires
            $alreadyUsed = array();

            // Boucle qui tourne 4 fois (car 4 images)
            for ($i = 0; $i < 4; $i++) {
              do {
                // Chiffre aléatoire entre 0 et 1
                $random = rand(0, 2);
                $sqlQuery = "";

                // Si 0, alors Pokémon
                if ($random == 0) {
                  $sqlQuery = "SELECT numero AS id, image FROM pokedex ORDER BY RANDOM() LIMIT 1";
                }
                // Si 1, alors lieu
                else if ($random == 1) {
                  $sqlQuery = "SELECT id, image FROM lieu ORDER BY RANDOM() LIMIT 1";
                } else if ($random == 2) {
                  $sqlQuery = "SELECT id, image FROM dresseur ORDER BY RANDOM() LIMIT 1";
                }

                // Récupérer les entrées
                $randomQuery = $pdo->query($sqlQuery);
                $randomQuery->execute(array());
                $randomReply = $randomQuery->fetchAll()[0];

                // Déclaration des bonnes variables pour l'affichage des images et les liens
                $entryId = $randomReply["id"];
                $entryImage = $randomReply["image"];
                if ($random == 0) // Pokémon
                {
                  $entryType = "pokedex/pokemon.php?id=";
                } else if ($random == 1) // Lieu
                {
                  $entryType = "lieu.php?id=";
                } else if ($random == 2) // Dresseur
                {
                  $entryType = "dresseur.php?id=";
                }

                $lookupStr = strval($random) . "_" . strval($entryId);
              }
              // Test si doublon
              while (in_array($lookupStr, $alreadyUsed));

              // Affichage
              print_r("<div class='col-md-4 col-lg-3'>
                                     <div class='item'><a href='$entryType$entryId'><img class='img-fluid scale-on-hover' src='$root$entryImage'></a></div>
                                   </div>");
              array_push($alreadyUsed, $lookupStr);
            }
            ?>
          </div>
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