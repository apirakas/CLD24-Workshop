function selectDresseur(event) {
    var dresseurId = event.id;

    fetch(`/combat/getPokemons.php?id=${dresseurId}`)
        .then(response => response.text())
        .then(htmlContent => {
            document.getElementById('selection').innerHTML = htmlContent;
        })
        .catch(error => console.error("Error fetching HTML content: ", error));
}
