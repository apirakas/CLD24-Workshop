<?php
// Path to root
$root = "./";

include $root . 'dbConnect.php';
setlocale(LC_ALL, "fr_CH");
?>

<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pokédex - Dresseurs</title>
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
          <h2>Dresseurs</h2>
        </div>
        <div class="row">
          <?php
          // Récupérer les dresseurs
          $dresseursQuery = $pdo->query("SELECT * FROM dresseur ORDER BY nom");
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
  <script src="<?= $root?>assets/js/jquery.min.js"></script>
  <script src="<?= $root?>assets/bootstrap/js/bootstrap.min.js"></script>
  <script src="<?= $root?>assets/js/theme.js"></script>
</body>

</html>