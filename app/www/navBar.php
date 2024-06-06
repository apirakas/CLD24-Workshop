<nav class="navbar navbar-dark navbar-expand-lg fixed-top bg-white portfolio-navbar gradient">
  <div class="container"><a class="navbar-brand logo" href="/index.php">Projet Pokémon</a><button class="navbar-toggler" data-toggle="collapse" data-target="#navbarNav"><span class="sr-only">Toggle navigation</span><span class="navbar-toggler-icon"></span></button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="nav navbar-nav ml-auto">
        <li class="nav-item" role="presentation"><a class="nav-link active" href="/region.php">Région</a></li>
        <li class="nav-item" role="presentation"><a class="nav-link active" href="/pokedex.php">Pokédex</a></li>
        <li class="nav-item" role="presentation"><a class="nav-link active" href="/dresseurs.php">Dresseurs</a></li>
        <li class="nav-item" role="presentation"><a class="nav-link active" href="/pokemons.php">Pokémons</a></li>
        <li class="nav-item" role="presentation"><a class="nav-link active" href="/combat/lobby.php">Combat</a></li>
      </ul>
      <ul class="nav navbar-nav ml-auto">
        <?php
        print_r("<li class='nav-item' role='presentation'><a class='active' href='$url'></a></li>")
        ?>
      </ul>
    </div>
  </div>
</nav>