# Thème Discourse — HACF

Thème du forum de la **Home Assistant Communauté Francophone** (HACF).

Identité : les couleurs du logo (dégradé bleu → violet → rouge), un mode clair et un mode sombre, le motif « arbre-circuit » du logo.

## État d'avancement

- [x] Étape 1 — squelette, deux palettes, polices embarquées, variables de marque
- [ ] Étape 2 — header, sidebar, barre de navigation des sujets
- [ ] Étape 3 — bannière d'accueil (halos + arbres-circuits)
- [ ] Étape 4 — cartes de catégories et liste des discussions
- [ ] Étape 5 — widgets de droite (événements, thèmes chauds)
- [ ] Étape 6 — mobile, finitions, contrastes

## Contenu

```
about.json            métadonnées, palettes "HACF Clair" / "HACF Sombre", assets
common/common.scss    polices, variables de marque
assets/hacf-logo.png  logo
assets/fonts/         Sora et Manrope (woff2, sous-ensemble latin) + licences OFL
```

## Installation

1. Pousser ce dossier dans un dépôt Git (GitHub).
2. Dans l'admin du forum : **Apparence → Thèmes et composants → Installer → Depuis un dépôt Git**.
3. Le thème n'est pas activé par défaut : l'ouvrir et utiliser l'aperçu avant de le définir comme thème par défaut.
4. Choisir la palette **HACF Clair** (et **HACF Sombre** pour le mode sombre) dans les réglages du thème.

## Polices

Sora (titres) et Manrope (texte), sous licence SIL Open Font License 1.1.
Fichiers servis par le forum lui-même : aucun appel à Google Fonts.

## Licence

À définir pour le code du thème. Les polices gardent leur licence d'origine (voir `assets/fonts/`).
