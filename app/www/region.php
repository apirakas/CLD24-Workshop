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
  <title>Pokédex - Région</title>
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
          <h2>Région</h2>
        </div>
        <div class="row">
          <?php
          // Récupérer les lieux
          $lieuxQuery = $pdo->query("SELECT * FROM lieu ORDER BY nom");
          $lieuxQuery->execute(array());
          $lieuxReply = $lieuxQuery->fetchAll();

          // Pour chaque entrée...
          foreach ($lieuxReply as $lieu) {
            // Déclarer les variables PHP avec les infos
            $lieuID = $lieu["id"];
            $lieuNom = $lieu["nom"];
            $lieuType = $lieu["nomtypelieu"];
            $lieuImage = $lieu["image"];

            // Affichage
            print_r("<div class='col-md-6 col-lg-4'>
                                 <div class='cardlieux border-0'><a href='lieu.php?id=$lieuID'><img src='$root$lieuImage' alt='Image de $lieuNom' class='lieuximage card-img-top lieuximage scale-on-hover'></a>
                                   <div class='card-body'>
                                     <h6><a href='lieu.php?id=$lieuID'>$lieuNom</a></h6>
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