# Thème Discourse — HACF

Thème du forum de la **Home Assistant Communauté Francophone** (HACF) — [forum.hacf.fr](https://forum.hacf.fr).

Identité : les couleurs du logo (dégradé bleu → violet → rouge), un mode clair et un mode sombre, le motif « arbre-circuit » du logo.

## Fonctionnalités

- **Accueil en grille (bento)** : bienvenue, dernières publications du blog, statistiques, événements à venir, équipe et « Comment ça marche ». Une bande d'avatars des contributeurs de la semaine et, pour les visiteurs, une invitation à rejoindre la communauté.
- **Équipe** affichée depuis le groupe `Equipe`, regroupée par titre de profil (fondateur, modérateur, etc.).
- **Fond global** : halo bleu → rouge, arbres « circuit » sur les côtés (grands écrans), motif d'icônes Home Assistant flouté.
- **Messages en cartes** dans les sujets, en clair et en sombre.
- **Administration et sidebar** habillées en cartes pour rester cohérentes avec le forum.
- **Pied de page** sur l'accueil : liens HACF, communauté et forum.
- **Palettes** « HACF Clair » et « HACF Sombre », polices Sora et Manrope embarquées.
- Textes en **français et anglais**.

## Paramètres

Réglables dans *Admin → Apparence → Thèmes et composants → HACF* :

| Paramètre | Rôle |
| --- | --- |
| Featured categories | Catégories mises en avant |
| Show hot topics / Hot topics count / Hot topics icon | Sujets populaires |
| Show upcoming events / Upcoming events count | Événements à venir |

## Prérequis

- Plugin **discourse-calendar** pour le bloc « Événements à venir ».
- Groupe **Equipe** lisible publiquement pour afficher l'équipe sur l'accueil.
- Articles du blog : sujets portant l'étiquette `hacf-blog`.

## Contenu

about.json métadonnées, palettes, assets, captures
common/common.scss styles du thème
javascripts/discourse/connectors/ accueil, footer et blocs de liste
locales/ fr.yml, en.yml
assets/hacf-logo.png logo
assets/fonts/ Sora et Manrope (woff2, sous-ensemble latin) + licences OFL
screenshots/ aperçus clair et sombre du sélecteur de thèmes


## Installation

1. Dans l'admin du forum : **Apparence → Thèmes et composants → Installer → Depuis un dépôt Git**.
2. URL : `https://github.com/barto95100/discourse-theme-hacf`.
3. Activer le thème par défaut et choisir les palettes **HACF Clair** et **HACF Sombre**.

## Mise à jour et retour arrière

- Mise à jour : bouton **Vérifier les mises à jour** sur la page du thème.
- Retour arrière : repasser un autre thème (par exemple Foundation) par défaut ; le thème HACF reste installé.

## Polices

Sora (titres) et Manrope (texte), sous licence SIL Open Font License 1.1.
Fichiers servis par le forum lui-même : aucun appel à Google Fonts.

## Licence

Code du thème sous licence MIT (voir `LICENSE`). Les polices gardent leur licence d'origine (voir `assets/fonts/`).
