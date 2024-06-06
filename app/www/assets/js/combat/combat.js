class Pokemon {
    player;
    name;
    maxHP;
    defaultAttack;
    defaultDefense;
    hp;
    attack;
    defense;
    specialAttack;
    specialDefense;
    capacities;
    speed;
    types;
    weaknesses;
    alive;


    constructor(player, json, mults) {
        this.player = player;
        this.name = json.espece;
        this.maxHP = json.pv;
        this.defaultAttack = json.attaque;
        this.defaultDefense = json.defense;
        this.hp = json.pv;
        this.attack = json.attaque;
        this.defense = json.defense;
        this.specialAttack = json.attaquespeciale;
        this.specialDefense = json.defensespeciale;
        this.capacities = json.capacites;
        this.speed = json.vitesse;
        this.types = json.types;
        this.weaknesses = {};
        this.computeWeaknesses(mults);
        this.alive = true;
        this.updateHealthBar();
    }

    computeWeaknesses(mults) {
        const baseTypeMultipliers = mults[this.types[0]];
    
        Object.keys(baseTypeMultipliers).forEach(type => {
            let finalMult = 1;
            this.types.forEach(pokemonType => {
                finalMult *= mults[pokemonType][type]; // Fix here
            });
            this.weaknesses[type] = finalMult;
        });
    }

    calculateDamage(capacity, targetPokemon) {
        return ((this.attack * capacity.puissance) / (targetPokemon.defense * 50) + 2)
    }

    calculateSpecialDamage(capacity, targetPokemon) {
        return ((this.specialAttack * capacity.puissance) / (targetPokemon.specialDefense * 50) + 2)
    }
    
    use(capacity, targetPokemon) {
        if (!this.alive || !targetPokemon.alive)
            return;

        console.log(capacity);
        
        if (capacity.statut === 'PASSIVE') {
            this.secondaryEffect(capacity, targetPokemon);
        } else if (capacity.statut === 'SPÉCIALE') {
            this.special(capacity, targetPokemon);
        } else {
            this.dealDamage(capacity, targetPokemon);
        }
    }

    dealDamage(capacity, targetPokemon) {
        const damage = this.calculateDamage(capacity, targetPokemon);
        const probability = capacity.precision / 100;
        const rng = Math.random();
        let hitMessage
        if (rng <= probability){
            const dealtDamage = targetPokemon.takeDamage(damage, capacity.type);
            hitMessage = ` ${targetPokemon.name} prend ${dealtDamage} dégâts.`;
        } else {

            hitMessage = `L'attaque "${capacity.nom}" a raté!`;
        }
        
        displayMessage(`${this.name} a utilisé l'attaque ${capacity.nom}. ${hitMessage}`);
    }

    takeDamage(damage, incomingType) {
        let damageTaken;
        if (incomingType === undefined) {
            damageTaken = Math.round(damage);
        } else {
            damageTaken = Math.round(damage * this.weaknesses[incomingType]);
        }
        this.hp = Math.max(this.hp - damageTaken, 0);

        this.updateHealthBar();

        if (this.hp === 0) {
            this.faint();
        }
        return damageTaken;
    }

    faint() {
        this.alive = false;
    }
    
    updateHealthBar() {
        const healthPercentage = (this.hp / this.maxHP) * 100;
        const healthBar = document.getElementById(`${this.player}-health-bar`);
        const healthText = document.getElementById(`${this.player}-hp`);
        
        let color = "green";
        if (healthPercentage < 30) {
            color = "red";
        } else if (healthPercentage < 70) {
            color = "orange";
        }

        healthBar.style.width = `${healthPercentage}%`;
        healthBar.style.backgroundColor = color;
        healthText.innerText = `${this.hp} / ${this.maxHP}`
    }

    secondaryEffect(capacity, targetPokemon) {
        const effect = capacity.effetsecondaire;
        let effectMessage;
        switch (effect) {
            case '10% de chances de faire perdre encore plus de cheveux au lanceur' :
                const probability = 0.10;
                const rng = Math.random();
                if (rng <= probability)
                    effectMessage = `${this.name} perd encore plus de cheveux`;
                else
                    effectMessage = `L'attaque "${capacity.nom}" a raté`;
                break;
            default:
                effectMessage = `L'attaque "${capacity.nom}" n'a aucun effet`;
                break;
        }
        displayMessage(`${this.name} a utilisé l'attaque ${capacity.nom}. ${effectMessage}`);
    }

    special(capacity, targetPokemon) {
        const damage = this.calculateSpecialDamage(capacity, targetPokemon);
        const probability = capacity.precision / 100;
        const rng = Math.random();
        let hitMessage
        if (rng <= probability) {
            const dealtDamage = targetPokemon.takeDamage(damage, capacity.type);
            hitMessage = ` ${targetPokemon.name} prend ${dealtDamage} dégâts.`;
        } else {
            hitMessage = `L'attaque "${capacity.nom}" a raté!`;
        }
        
        displayMessage(`${this.name} a utilisé l'attaque spéciale ${capacity.nom}. ${hitMessage}`);
    }
}

function displayMessage(message) {
    const output = document.getElementById('output');
    output.innerText = message;
}


const idPlayer = document.querySelector('.combat.pokemon.player').id;
const idOpponent = document.querySelector('.combat.pokemon.opponent').id;
const statsApiUrl = `/combat/getStats.php?idPlayer=${idPlayer}&idOpponent=${idOpponent}`
const pauseTime = 2000;

battleHandler();

async function getStats() {
    return fetch(statsApiUrl)
        .then(response => response.json())
        .then(data => {
            console.log(data);
            return {
                player: new Pokemon("player", data.player, data.multiplicateurs),
                opponent: new Pokemon("opponent", data.opponent, data.multiplicateurs)
            };
        })
        .catch(error => {
            console.error('Error fetching data:', error);
        });
}

function getAllCapacityElements(player) {
    let capacityElements = [];
    
    for (let i = 0; i < player.capacities.length; i++) {
        const capacityElement = document.getElementById(`capacity-${i}`);
        
        if (capacityElement) {
            capacityElements.push(capacityElement);
        }
    }
    
    return capacityElements;
}

function waitForPlayerAction(buttons) {
    return new Promise(resolve => {
        // Show the modal before waiting for player action
        $('#capacities').modal('show');
        
        buttons.forEach((element, index) => {
            element.addEventListener('click', function onClick() {
                // Remove the event listener to avoid multiple clicks
                buttons.forEach(el => el.removeEventListener('click', onClick));

                // Hide the modal after selecting a capacity
                $('#capacities').modal('hide');

                const idCapacity = element.id.split('-')[1];

                resolve(idCapacity);
            });
        });
    });
}

async function battleHandler() {
    try {
        const { player, opponent } = await getStats();
        const playerCapacityElements = getAllCapacityElements(player);
        
        let playerTurn = player.speed > opponent.speed;

        let message;
        
        if (playerTurn)
            message = `${player.name} commence!`;
        else
            message = `${opponent.name} commence!`;

        displayMessage(message);
        
        await sleep(pauseTime);
        
        while (player.alive && opponent.alive) {
            if (playerTurn) {
                if (player.capacities.length != 0) {
                    await waitForPlayerAction(playerCapacityElements).then(clickedCapacityId => {
                        player.use(player.capacities[clickedCapacityId], opponent);
                    });
                } else {
                    message = `${player.name} n'a plus d'attaques. ${player.name} passe son tour!`;
                    displayMessage(message);
                    await sleep(pauseTime);
                }
            } else {
                if (opponent.capacities.length != 0) {
                    const randomIndex = Math.floor(Math.random() * opponent.capacities.length);
                    const randomCapacity = opponent.capacities[randomIndex];
                    opponent.use(randomCapacity, player);
                } else {
                    message = `${opponent.name} n'a plus d'attaques. ${opponent.name} passe son tour!`;
                    displayMessage(message);
                    await sleep(pauseTime);
                }
            }
            
            await sleep(pauseTime);

            // Switch turn
            playerTurn = !playerTurn;


            if (player.alive && opponent.alive){
                if (playerTurn){
                    message = `C'est au tour de ${player.name}!`;
                } else {
                    message = `C'est au tour de ${opponent.name}!`;
                }
                displayMessage(message);
            }
            await sleep(pauseTime);
        }

        if(player.alive) {
            displayMessage(`${opponent.name} est mort!`)
        } else {
            displayMessage(`${player.name} est mort!`)
        }
    } catch (error) {
        console.error('Error in battleHandler:', error);
    }
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}