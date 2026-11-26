## 1.3.0
- Le numéro de version de l'appli s'affiche en bas de l'écran d'ouverture, dès le logo Ysdad et pendant l'image de l'appli (ex. « Version 1.0.31 (2031) »). Texte petit, centré, contrastant avec le fond.
- La version est lue automatiquement (`package_info_plus`). On peut aussi passer le libellé avec `versionLabel`, ou masquer l'affichage avec `showVersion: false` (affichage activé par défaut).
- L'API existante et le cadrage (`BoxFit.contain`, fond flouté assorti) restent inchangés.

## 1.2.0
- Les images d'ouverture occupent le plus d'espace possible, restent entières et ne sont jamais déformées (`BoxFit.contain`).
- Fond automatique : version floutée et agrandie de l'image, avec un léger voile sombre en dégradé. On peut toujours imposer une couleur unie avec `backgroundColor`.
- `logoMaxWidth` n'a plus de limite par défaut (plein écran). Pour retrouver l'ancien cadrage : `logoMaxWidth: 280`.

## 1.1.0
- Paquet Flutter (`ysdad_ouverture`) utilisable en dépendance Git; le logo Ysdad est inclus dans le paquet
  (`kYsdadProgrammerLogoPackageAsset`).
- Aucun changement de comportement : copier `lib/ysdad_ouverture.dart` et `assets/ysdad-logo.png` fonctionne comme avant.

## 1.0.0
- Écran d'ouverture : logo programmeur 3 s, puis image de l'appli 2 s (facultative).
