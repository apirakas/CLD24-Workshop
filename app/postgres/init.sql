DROP DATABASE IF EXISTS workshopcld;

CREATE DATABASE workshopcld;

CREATE DOMAIN FILE VARCHAR(255) NOT NULL;

-- Création de la table TypeLieu
CREATE TABLE TypeLieu (
	nom VARCHAR(255) PRIMARY KEY
);

-- Création de la table Lieu
CREATE TABLE Lieu (
    id SERIAL,
    nom VARCHAR(255) NOT NULL,
    nomTypeLieu VARCHAR(255) NOT NULL,
    image FILE NOT NULL,
	CONSTRAINT PK_Lieu PRIMARY KEY (id),
    CONSTRAINT FK_Lieu_nomTypeLieu FOREIGN KEY (nomTypeLieu) REFERENCES TypeLieu(nom) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT UC_Lieu_nom UNIQUE (nom),
    CONSTRAINT UC_Lieu_image UNIQUE (image)
);

-- Création de la table PointDInteret
CREATE TABLE PointDInteret (
    id SERIAL,
    idLieu INT NOT NULL,
    nom VARCHAR(255) NOT NULL,
    CONSTRAINT PK_PointDInteret PRIMARY KEY (id),
    CONSTRAINT FK_PointDInteret_idLieu FOREIGN KEY (idLieu) REFERENCES Lieu(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de l'enum TypeDresseur
CREATE TYPE TypeDresseur AS ENUM ('JOUEUR', 'TEAM ROCKET', 'PÊCHEUR', 'CHAUVE', 'GAMIN', 'PROF');

-- Création de l'enum Sexe
CREATE TYPE Sexe AS ENUM ('MÂLE', 'FEMELLE', 'ASEXUÉ');

-- Création de l'enum StatutAttaque
CREATE TYPE StatutAttaque AS ENUM ('PHYSIQUE', 'SPÉCIALE', 'PASSIVE');

-- Création de la table Dresseur
CREATE TABLE Dresseur (
    id SERIAL,
    idLieu INT NOT NULL,
    nom VARCHAR(255) NOT NULL,
    type TypeDresseur NOT NULL,
	sexe Sexe NOT NULL,
    image FILE NOT NULL,
    CONSTRAINT PK_Dresseur PRIMARY KEY (id),
    CONSTRAINT FK_Dresseur_idLieu FOREIGN KEY (idLieu) REFERENCES Lieu(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT UC_Dresseur_image UNIQUE (image)
);

-- Création de la table Pokédex
CREATE TABLE Pokedex (
    numero SERIAL,
    espece VARCHAR(255) NOT NULL,
    legendaire BOOLEAN NOT NULL,
    taille FLOAT NOT NULL,
    poids FLOAT NOT NULL,
    PV INT NOT NULL,
    attaque INT NOT NULL,
    defense INT NOT NULL,
    attaqueSpeciale INT NOT NULL,
    defenseSpeciale INT NOT NULL,
    vitesse INT NOT NULL,
    image FILE UNIQUE,
	CONSTRAINT PK_Pokedex PRIMARY KEY (numero),
    CONSTRAINT UC_Pokedex_espece UNIQUE (espece),
    CONSTRAINT UC_Pokedex_image UNIQUE (image)
);

-- Création de la table Pokémon
CREATE TABLE Pokemon (
    numero INT,
    id SERIAL,
    idDresseur INT,
    sexe Sexe NOT NULL,
    shiny BOOLEAN NOT NULL DEFAULT FALSE,
    idLieu INT NOT NULL,
    CONSTRAINT PK_Pokemon PRIMARY KEY (numero, id),
    CONSTRAINT FK_Pokemon_numero FOREIGN KEY (numero) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Pokemon_idDresseur FOREIGN KEY (idDresseur) REFERENCES Dresseur(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_Pokemon_idLieu FOREIGN KEY (idLieu) REFERENCES Lieu(id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- CI : Un pokemon se trouve au même lieu que son Dresseur s'il en a un
CREATE OR REPLACE FUNCTION CK_Pokemon_Meme_Lieu_Que_Dresseur() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE DresseurIdLieu INT;
    BEGIN
        IF NEW.idDresseur IS NULL THEN
            RETURN NEW;
        ELSE
            SELECT Dresseur.idLieu INTO DresseurIdLieu
            FROM Dresseur
            WHERE Dresseur.id = NEW.idDresseur;
            RETURN (NEW.numero, NEW.id, NEW.idDresseur, NEW.sexe, NEW.shiny, DresseurIdLieu);
        END IF;
    END;
$$;

-- Déclaration du déclencheur CK_Pokemon_Meme_Lieu_Que_Dresseur_insert
CREATE TRIGGER trigger_ck_meme_lieu_que_dresseur_insert
BEFORE INSERT ON Pokemon
FOR EACH ROW
EXECUTE PROCEDURE CK_Pokemon_Meme_Lieu_Que_Dresseur();

-- Déclaration du déclencheur CK_Pokemon_Meme_Lieu_Que_Dresseur_update
CREATE TRIGGER trigger_ck_meme_lieu_que_dresseur_update
BEFORE UPDATE ON Pokemon
FOR EACH ROW
EXECUTE PROCEDURE CK_Pokemon_Meme_Lieu_Que_Dresseur();


-- CI : Tous les Pokemons du Dresseur se déplacent avec lui
CREATE OR REPLACE FUNCTION CK_Dresseur_Pokemon_Suit() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    BEGIN
        IF OLD.idLieu != NEW.idLieu THEN
            UPDATE Pokemon SET Pokemon.idLieu = NEW.idLieu WHERE Pokemon.idDresseur = NEW.id;
        END IF;
    END;
$$;

-- Déclaration du déclencheur CK_Dresseur_Pokemon_Suit
CREATE TRIGGER trigger_ck_dresseur_pokemon_suit
AFTER UPDATE ON Dresseur
FOR EACH ROW
EXECUTE PROCEDURE CK_Dresseur_Pokemon_Suit();

-- Création de la table EffetSecondaire
CREATE TABLE EffetSecondaire (
    id SERIAL,
    effet VARCHAR(255) NOT NULL,
	CONSTRAINT PK_EffetSecondaire PRIMARY KEY (id),
    CONSTRAINT UC_EffetSecondaire_effet UNIQUE (effet)
);

-- Création de la table TypeElementaire
CREATE TABLE TypeElementaire (
    nom VARCHAR(255) PRIMARY KEY
);

-- Création de la table Multiplicateur
CREATE TABLE Multiplicateur (
    typeSource VARCHAR(255),
    typeDestination VARCHAR(255),
    multiplicateur FLOAT NOT NULL,
    CONSTRAINT PK_Multiplicateur PRIMARY KEY (typeSource, typeDestination),
    CONSTRAINT FK_Multiplicateur_typeSource FOREIGN KEY (typeSource) REFERENCES TypeElementaire(nom) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Multiplicateur_typeDestination FOREIGN KEY (typeDestination) REFERENCES TypeElementaire(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de la table TypePokedex
CREATE TABLE TypePokedex (
    numeroPokedex INT,
    nomTypeElementaire VARCHAR(255) NOT NULL,
    CONSTRAINT PK_TypePokedex PRIMARY KEY (numeroPokedex, nomTypeElementaire),
    CONSTRAINT FK_TypePokedex_numeroPokedex FOREIGN KEY (numeroPokedex) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_TypePokedex_nomTypeElementaire FOREIGN KEY (nomTypeElementaire) REFERENCES TypeElementaire(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de la table Capacite
CREATE TABLE Capacite (
    nom VARCHAR(255),
    statut StatutAttaque NOT NULL,
    puissance INT NOT NULL,
    PP INT NOT NULL,
    precision INT NOT NULL,
    idEffetSecondaire INT,
    nomType VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Capacite PRIMARY KEY (nom),
    CONSTRAINT FK_Capacite_idEffetSecondaire FOREIGN KEY (idEffetSecondaire) REFERENCES EffetSecondaire(id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT FK_Capacite_nomType FOREIGN KEY (nomType) REFERENCES TypeElementaire(nom) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CK_Capacite_precision CHECK(precision BETWEEN 0 AND 100)
);

-- Création de la table PokedexCapacitePool
CREATE TABLE PokedexCapacitePool (
    numeroPokedex INT,
    nomCapacite VARCHAR(255) NOT NULL,
    CONSTRAINT PK_PokedexCapacitePool PRIMARY KEY (numeroPokedex, nomCapacite),
    CONSTRAINT FK_PokedexCapactiePool_numeroPokedex FOREIGN KEY (numeroPokedex) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_PokedexCapactiePool_nomCapacite FOREIGN KEY (nomCapacite) REFERENCES Capacite(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de la table PokemonCapacite
CREATE TABLE PokemonCapacite (
    numeroPokemon INT,
    idPokemon INT,
    nomCapacite VARCHAR(255),
    CONSTRAINT PK_PokemonCapacite PRIMARY KEY (numeroPokemon, idPokemon, nomCapacite),
    CONSTRAINT FK_PokemonCapacite_Pokemon FOREIGN KEY (numeroPokemon, idPokemon) REFERENCES Pokemon(numero, id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_PokemonCapacite_nomCapacite FOREIGN KEY (numeroPokemon, nomCapacite) REFERENCES PokedexCapacitePool(numeroPokedex, nomCapacite) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de la table PokemonLieu
CREATE TABLE PokedexLieu (
    numeroPokedex INT,
    nomTypeLieu VARCHAR(255),
    CONSTRAINT PK_PokedexLieu PRIMARY KEY (numeroPokedex, nomTypeLieu),
    CONSTRAINT FK_PokemonLieu_numeroPokedex FOREIGN KEY (numeroPokedex) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_PokemonLieu_nomTypeLieu FOREIGN KEY (nomTypeLieu) REFERENCES TypeLieu(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Création de la table EvolutionPokedex
CREATE TABLE EvolutionPokedex (
    base INT,
    evolution INT,
    CONSTRAINT PK_EvolutionPokedex PRIMARY KEY (base, evolution),
    CONSTRAINT FK_EvolutionPokedex_base FOREIGN KEY (base) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_EvolutionPokedex_evolution FOREIGN KEY (evolution) REFERENCES Pokedex(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT BaseEvolution CHECK (base != evolution) -- Un Pokémon ne peut pas évoluer en lui-même.
);

-- Déclaration de la fonction CK_Pokemon_LieuValide servant comme contrainte de lieu
CREATE OR REPLACE FUNCTION CK_Pokemon_LieuValide() RETURNS TRIGGER
AS $$
BEGIN
    IF (SELECT Lieu.nomtypelieu IN (SELECT pokedexLieu.nomtypelieu
								FROM pokedexLieu
								WHERE numeropokedex = new.numero)
		FROM Lieu
		WHERE Lieu.id = new.idLieu) OR (NEW.idDresseur IS NOT NULL) THEN
		RETURN NEW;
    ELSE
    	RAISE EXCEPTION 'Le pokémon ne peut pas apparaître dans ce type de lieu: %', (SELECT typelieu.nom FROM typelieu INNER JOIN lieu ON lieu.nomtypelieu = typelieu.nom WHERE lieu.id = new.idlieu);
    END IF;
END;
$$
LANGUAGE plpgsql;

-- Déclaration du déclencheur CK_Pokemon_LieuValide
CREATE TRIGGER trigger_ck_pokemon_lieuvalide
BEFORE INSERT ON Pokemon
FOR EACH ROW
EXECUTE PROCEDURE CK_Pokemon_LieuValide();

-- Déclaration de la CI vérifiant si le pokemon n'a que des capacités autorisées
CREATE OR REPLACE FUNCTION CK_PokemonCapaciteValide()
RETURNS TRIGGER
AS $$
BEGIN
	IF (new.nomCapacite IN (SELECT nomCapacite
								FROM PokedexCapacitePool
								WHERE numeropokedex = new.numeroPokemon)) THEN
			RETURN new;
	ELSE
		RAISE EXCEPTION 'Cette capacité n est pas autorisée par le Pokédex : %', (new.nomCapacite);
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER CK_PokemonCapaciteValide_insert
BEFORE INSERT ON pokemonCapacite
FOR EACH ROW
EXECUTE PROCEDURE CK_PokemonCapaciteValide();

CREATE TRIGGER CK_PokemonCapaciteValide_update
BEFORE UPDATE ON pokemonCapacite
FOR EACH ROW
EXECUTE PROCEDURE CK_PokemonCapaciteValide();

------------------------
-- Insertion des données
------------------------

-- Insertion des types élémentaires
INSERT INTO typeelementaire(nom) VALUES ('Acier');
INSERT INTO typeelementaire(nom) VALUES ('Combat');
INSERT INTO typeelementaire(nom) VALUES ('Dragon');
INSERT INTO typeelementaire(nom) VALUES ('Eau');
INSERT INTO typeelementaire(nom) VALUES ('Électrique');
INSERT INTO typeelementaire(nom) VALUES ('Feu');
INSERT INTO typeelementaire(nom) VALUES ('Glace');
INSERT INTO typeelementaire(nom) VALUES ('Insecte');
INSERT INTO typeelementaire(nom) VALUES ('Normal');
INSERT INTO typeelementaire(nom) VALUES ('Plante');
INSERT INTO typeelementaire(nom) VALUES ('Poison');
INSERT INTO typeelementaire(nom) VALUES ('Psy');
INSERT INTO typeelementaire(nom) VALUES ('Roche');
INSERT INTO typeelementaire(nom) VALUES ('Sol');
INSERT INTO typeelementaire(nom) VALUES ('Spectre');
INSERT INTO typeelementaire(nom) VALUES ('Ténèbres');
INSERT INTO typeelementaire(nom) VALUES ('Vol');

-- Insertion des Pokémons
INSERT INTO pokedex(numero, espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES (6969, 'Pointeurentsch', TRUE, 1.65, 32, 60, 100, 110, 80, 130, 40, 'assets/img/pokemons/pointeurentsch.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Bulbizarre', FALSE, 0.7, 6.9, 45, 49, 49, 65, 65, 45, 'assets/img/pokemons/bulbizarre.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Herbizarre', FALSE, 1, 13, 60, 62, 63, 80, 80, 60, 'assets/img/pokemons/herbizarre.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Florizarre', FALSE, 2, 100, 80, 82, 83, 100, 100, 80, 'assets/img/pokemons/florizarre.png');
INSERT INTO pokedex(numero, espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES (6970, 'Noeunoeufabrice', TRUE, 0.4, 2.5, 60, 40, 80, 60, 45, 40, 'assets/img/pokemons/noeunoeufabrice.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Noadkoko', FALSE, 2, 120, 95, 95, 85, 125, 75, 55, 'assets/img/pokemons/noadkoko.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Noadkoko d’Alola', FALSE, 10.9, 415.6, 95, 105, 85, 125, 75, 45, 'assets/img/pokemons/noadkokoalola.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Cacnea', FALSE, 0.4, 51.3, 50, 85, 40, 85, 40, 35, 'assets/img/pokemons/cacnea.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Cacturne', FALSE, 1.3, 77.4, 70, 115, 60, 115, 60, 55, 'assets/img/pokemons/cacturne.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Ponyta', FALSE, 1.0, 30.0, 50, 85, 55, 65, 65, 90, 'assets/img/pokemons/ponyta.png');
INSERT INTO pokedex(espece, legendaire, taille, poids, pv, attaque, defense, attaquespeciale, defensespeciale, vitesse, image)
VALUES ('Pedrobear', TRUE, 1.80, 70.0, 50, 80, 80, 80, 80, 120, 'assets/img/pokemons/pedrobear.png');

-- Evolutions
INSERT INTO evolutionpokedex(base, evolution)
VALUES (6970, 4);
INSERT INTO evolutionpokedex(base, evolution)
VALUES (4, 5);
INSERT INTO evolutionpokedex(base, evolution)
VALUES (1, 2);
INSERT INTO evolutionpokedex(base, evolution)
VALUES (2, 3);

-- Insertion des types de lieux
INSERT INTO typelieu(nom) VALUES ('Ville');
INSERT INTO typelieu(nom) VALUES ('Grotte');
INSERT INTO typelieu(nom) VALUES ('Route');
INSERT INTO typelieu(nom) VALUES ('Plaine');
INSERT INTO typelieu(nom) VALUES ('Désert');

-- Insertion des lieux
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Bourg Palette', 'Ville', 'assets/img/lieux/bourgpalette.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Lavanville', 'Ville', 'assets/img/lieux/lavanville.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Route 1', 'Route', 'assets/img/lieux/route1.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Caverne Azurée', 'Grotte', 'assets/img/lieux/caverneazuree.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Cramois Île', 'Ville', 'assets/img/lieux/cramoisile.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Plaines d’Obsidienne', 'Plaine', 'assets/img/lieux/plainesobsidienne.png');
INSERT INTO lieu(nom, nomtypelieu, image) VALUES ('Désert Fournaise', 'Désert', 'assets/img/lieux/desertfournaise.png');

-- Insertion des types de lieux où des espèces de Pokémons peuvent apparaître
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (8, 'Plaine');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (6, 'Désert');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (7, 'Désert');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (1, 'Plaine');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (4, 'Route');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (4, 'Plaine');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (5, 'Grotte');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (5, 'Route');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (5, 'Plaine');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (9, 'Grotte');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (6969, 'Grotte');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (6969, 'Ville');
INSERT INTO pokedexlieu (numeropokedex, nomtypelieu) VALUES (6970, 'Désert');

-- Insertion des dresseurs
INSERT INTO dresseur(idlieu, nom, type, sexe, image) VALUES (3, 'Fabrice', 'CHAUVE', 'MÂLE', 'assets/img/dresseurs/fabrice.png');
INSERT INTO dresseur(idlieu, nom, TYPE, sexe, image) VALUES (1, 'Naoko', 'GAMIN', 'FEMELLE', 'assets/img/dresseurs/naoko.png');
INSERT INTO dresseur(idlieu, nom, TYPE, sexe, image) VALUES (5, 'Auguste', 'PROF', 'MÂLE', 'assets/img/dresseurs/auguste.png');
INSERT INTO dresseur(idlieu, nom, TYPE, sexe, image) VALUES (2, 'Jean', 'GAMIN', 'MÂLE', 'assets/img/dresseurs/jean.png');
INSERT INTO dresseur(idlieu, nom, TYPE, sexe, image) VALUES (6, 'Gillette', 'PROF', 'FEMELLE', 'assets/img/dresseurs/gillette.png');
INSERT INTO dresseur(idlieu, nom, TYPE, sexe, image) VALUES (4, 'Pedro', 'GAMIN', 'MÂLE', 'assets/img/dresseurs/pedro.png');
SELECT * FROM dresseur;

-- Insertion des Points D'Intérêt
INSERT INTO pointdinteret(idlieu, nom) VALUES (5, 'Manoir Pokémon');
INSERT INTO pointdinteret(idlieu, nom) VALUES (5, 'Laboratoire');

-- Insertion des types des Pokémons dans le Pokédex
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (1, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (1, 'Poison');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (2, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (2, 'Poison');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (3, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (3, 'Poison');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (4, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (4, 'Psy');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (5, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (5, 'Psy');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (6, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (7, 'Plante');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (7, 'Ténèbres');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (8, 'Feu');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (9, 'Psy');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (9, 'Ténèbres');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (6969, 'Ténèbres');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (6969, 'Spectre');
INSERT INTO typepokedex(numeropokedex, nomtypeelementaire) VALUES (6970, 'Combat');

-- Insertion des Pokemons (Instances)
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (4, 2, 'MÂLE', FALSE, 5);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (8, 3, 'FEMELLE', FALSE, 5);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (6970, 5, 'FEMELLE', TRUE, 6);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (1, NULL, 'FEMELLE', TRUE, 6);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (2, 4, 'MÂLE', FALSE, 2);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (3, 2, 'MÂLE', FALSE, 1);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (4, NULL, 'FEMELLE', FALSE, 3);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (5, NULL, 'FEMELLE', TRUE, 4);
INSERT INTO pokemon (numero, idDresseur, sexe, shiny, idLieu)
VALUES (9, 6, 'MÂLE', TRUE, 4);

-- Insertion des Effets Secondaires
INSERT INTO effetsecondaire (effet) VALUES ('10% de chances de faire perdre encore plus de cheveux au lanceur');

-- Insertions des capacités
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Charge', 'PHYSIQUE', 40, 35, 100, NULL, 'Normal');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Rugissement', 'PASSIVE', 0, 40, 100, NULL, 'Normal');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Mimi-Queue', 'PASSIVE', 0, 30, 100, NULL, 'Normal');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Flammèche', 'SPÉCIALE', 40, 25, 100, NULL, 'Feu');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Fouet Lianes', 'PHYSIQUE', 45, 25, 100, NULL, 'Plante');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Croissance', 'PASSIVE', 0, 25, 100, NULL, 'Normal');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Tempête Florale', 'PHYSIQUE', 90, 15, 100, NULL, 'Plante');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Danse Fleurs', 'SPÉCIALE', 120, 10 ,100, NULL, 'Plante');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Balle Graine', 'PHYSIQUE', 25, 30, 100, NULL, 'Plante');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Brouhaha', 'SPÉCIALE', 90, 10, 100, NULL, 'Normal');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Canon Graine', 'PHYSIQUE', 80, 15, 100, NULL, 'Plante');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Choc Mental', 'SPÉCIALE', 50, 25, 100, NULL, 'Psy');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Dard-Venin', 'PHYSIQUE', 15 ,35, 100, NULL, 'Poison');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Groz’Yeux', 'PASSIVE', 0, 30, 100, NULL, 'Normal');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Vole-Vie', 'SPÉCIALE', 20, 25, 100, NULL, 'Plante');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Vendetta', 'PHYSIQUE', 60, 10, 100, NULL, 'Combat');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Aveuglement', 'SPÉCIALE', 69, 30, 100, NULL, 'Roche');
INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Kalvas', 'PASSIVE', 0, 5, 80, 1, 'Vol');

INSERT INTO capacite (nom, statut, puissance, pp, PRECISION, idEffetSecondaire, nomType)
VALUES ('Chasse', 'PASSIVE', 0, 35, 100, NULL, 'Vol');

-- Insertions capacites autorisées
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6970, 'Aveuglement');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6970, 'Kalvas');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (7, 'Dard-Venin');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (7, 'Groz’Yeux');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (7, 'Vole-Vie');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (7, 'Croissance');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (7, 'Vendetta');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6, 'Dard-Venin');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6, 'Groz’Yeux');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6, 'Vole-Vie');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (6, 'Croissance');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (8, 'Charge');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (8, 'Rugissement');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (8, 'Mimi-Queue');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (8, 'Flammèche');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (1, 'Charge');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (1, 'Rugissement');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (1, 'Fouet Lianes');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (1, 'Croissance');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (2, 'Charge');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (2, 'Rugissement');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (2, 'Fouet Lianes');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (2, 'Croissance');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Charge');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Rugissement');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Fouet Lianes');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Croissance');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Tempête Florale');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (3, 'Danse Fleurs');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (4, 'Balle Graine');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (4, 'Brouhaha');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (4, 'Canon Graine');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (4, 'Choc Mental');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (5, 'Balle Graine');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (5, 'Brouhaha');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (5, 'Canon Graine');
INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (5, 'Choc Mental');

INSERT INTO pokedexcapacitepool (numeroPokedex, nomCapacite)
VALUES (9, 'Chasse');


-- Insertion des capacités de chaque pokemon
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (6970, 3, 'Aveuglement');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (6970, 3, 'Kalvas');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (1, 4, 'Charge');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (1, 4, 'Rugissement');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (2, 5, 'Fouet Lianes');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (2, 5, 'Croissance');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (3, 6, 'Fouet Lianes');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (3, 6, 'Tempête Florale');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (4, 7, 'Choc Mental');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (5, 8, 'Choc Mental');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (5, 8, 'Canon Graine');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (5, 8, 'Brouhaha');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (8, 2, 'Flammèche');
INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (8, 2, 'Mimi-Queue');

INSERT INTO pokemoncapacite (numeroPokemon, idPokemon, nomCapacite)
VALUES (9, 9, 'Chasse');

-- Insertion des multiplicateurs
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Roche', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Spectre', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Feu', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Eau', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Plante', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Glace', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Insecte', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Roche', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Dragon', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Acier', 2);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Feu', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Eau', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Plante', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Dragon', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Feu', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Eau', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Plante', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Poison', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Sol', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Vol', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Insecte', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Dragon', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Eau', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Plante', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Électrique', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Sol', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Vol', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Dragon', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Feu', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Eau', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Plante', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Glace', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Sol', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Vol', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Dragon', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Acier', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Normal', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Glace', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Combat', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Vol', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Psy', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Insecte', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Spectre', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Ténèbres', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Acier', 2);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Plante', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Poison', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Sol', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Roche', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Spectre', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Acier', 0);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Feu', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Plante', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Électrique', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Poison', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Vol', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Insecte', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Acier', 2);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Plante', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Électrique', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Combat', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Insecte', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Combat', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Poison', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Psy', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Ténèbres', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Feu', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Plante', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Combat', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Poison', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Vol', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Psy', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Ténèbres', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Feu', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Glace', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Combat', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Sol', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Vol', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Insecte', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Normal', 0);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Psy', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Spectre', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Ténèbres', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Spectre', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Combat', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Psy', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Spectre', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Ténèbres', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Feu', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Plante', 0.5);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Glace', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Roche', 2);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Acier', 0.5);

INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Normal', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Feu', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Eau', 'Acier', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Plante', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Électrique', 'Acier', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Glace', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Combat', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Poison', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Sol', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Vol', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Psy', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Insecte', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Roche', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Spectre', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Dragon', 'Ténèbres', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Feu', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Plante', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Glace', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Roche', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Ténèbres', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Normal', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Eau', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Électrique', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Combat', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Poison', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Sol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Vol', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Psy', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Insecte', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Spectre', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Dragon', 1);
INSERT INTO multiplicateur (typesource, typedestination, multiplicateur)
VALUES ('Acier', 'Ténèbres', 1);
