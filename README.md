# Azure

## POC objectives

<Validate the possible use of .... in the context of ....>

## Infra architecture

<Logical components, ports/protocols, cloud type.>

- Logical components : Database, PHP instances, Load-balancer
- Ports / Protocols : HTTPS between client and server, HTTP inside
- Cloud type : IaaS

## Scenario

Describe step-by-step the scenario. Write it using this format (BDD style).

### STEP 01

- **Given** : Idée de site web
- **When** : Développement d'un site Web en PHP
- **Then** : 1 Simple instance statique en PHP accessible depuis le web

### STEP 02

- **Given** : Instance stateful
- **When** : Mise en place d'une database afin de rendre l'instance stateless et que seul la database soit stateful
- **Then** : 1 Simple instance en PHP accessible depuis le web avec les données stockées hors de l'instance

### STEP 03

- **Given** : Instance seul susceptible d'être sur-chargée
- **When** : Mise en place d'un load balancer permettant la variation des instances disponibles
- **Then** : Infrastructure qui gère automatiquement les ressources allouées afin que le tout fonctionne avec des performances raisonnables

### STEP 04

- **Given** : Infrastructure complète accessible depuis internet
- **When** : Stress test de l'infra afin de vérifier la bonne élasticité et qu'on ne se retrouve ni en manque de ressources, ni en surplus (pour ne pas sûr-payer)
- **Then** : Infrastructure **fine tuned** pour l'utilisation désirée

## Cost

<analysis of load-related costs.>

<option to reduce or adapt costs (practices, subscription)>

## Return of experience

<take a position on the poc that has been produced.>

<Did it validate the announced objectives?>
