# Compte-rendu projet programmation : compilateur

## Partie 1 - typing

Le codage du typage de chaque expression a été réalisé.

Voici la description de quelques éléments qui me semblent pertinents et pas forcément évidents :

En particulier pour les assignations, les cas suivants ont été méticuleusement traité :
 - Autorisation d'assigner la valeur nil à une variable de type pointeur.
 - Autorisation d'assigner tout ce qu'on veut à la variable "_", autant de fois qu'on veut dans un bloc.
 - Interdiction de déclarer plusieurs variables avec le même nom dans un même bloc (exception pour "_") : pour ça, j'ai sorti l'identifiant unique des variables de la fonction `new_var` pour pouvoir y avoir accès en dehors de la fonction, et quand j'entre dans un bloc, j'enregistre l'identifiant actuel de la dernière variable déclarée. Ainsi, toutes les variables dans le bloc aurant un identifiant supérieur à cette valeur, et si jamais je tombe sur un nom déjà utilisé, je vérifie si elle a été déclarée dans le bloc en comparant à la valeur d'entrée du bloc.

Pour la déclaration de variable, je me suis posée la question suivante : puisque dans le TAST, on récupère uniquement une liste de variables et qu'on peut déclarer des variables en leur assignant directement une valeur, on perd l'information de l'assignation, alors comment faire ? J'ai donc décidé dans les cas où on déclare en assignant de renvoyer une expression `TEblock` composé d'une expression `TEvars` suivie d'une expression `TEassign` pour ne perdre aucune information. 

Pour gérer la portée d'une variable au sein d'un bloc, je stocke mon environnement dans une référence, et avant d'entrée dans un bloc, je garde en mémoire l'état de l'environnement à ce moment là. Ainsi quand je sors du bloc, je n'ai qu'à remettre ma référence à jour avec l'ancien environnement que j'avais gardé.

Je considère qu'une variable est _used_ uniquement si elle a été utilisée autrement que lors de sa déclaration ou d'une assignation (en tant que l-value). 

Je vérifie que `TEdot (v,f)` est une l-value si `v` est une l-value. Et je vérifie bien quand il y a besoin que les expressions qu'on traite sont des l-value.

Au delà de ça, j'ai a priori fait toutes les vérifications nécessaires, entre autre sur l'utilisation de `fmt` ou la déclaration du `main`. Mon compilateur réussit tous les tests fournis et j'ai rajouté quelques tests faux. 


