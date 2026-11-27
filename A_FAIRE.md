# À faire — module Ouverture

## Décisions

- 23 novembre 2026 : afficher le numéro de version de l'appli en bas de l'écran d'ouverture, dès le logo Ysdad et pendant l'image de l'appli. Texte petit, discret mais lisible, centré en bas, contrastant avec le fond (ex. « Version 1.0.31 (2031) »). Récupération automatique via `package_info_plus`, avec possibilité de passer le libellé (`versionLabel`) ou de masquer l'affichage (`showVersion: false`). Affichage activé par défaut. L'API existante et le cadrage (`BoxFit.contain`, fond assorti) restent inchangés.
- 23 novembre 2026 : la v1.3.0 a été fusionnée dans `main` (squash dfea9b8). Les applis l'obtiendront à leur prochaine mise à jour. Aucune appli n'a été recompilée à la fusion.
- 26 novembre 2026 : afficher avec le numéro de version la date et l'heure de publication de cette version, ex. « Version 1.0.31 (2031) · publiée le 26 nov. 2026 à 19 h 15 » (format français, heure de Montréal / America/Toronto). La date est inscrite à la compilation avec `--dart-define=YSDAD_BUILD_DATE=...` (ISO 8601), lue par `String.fromEnvironment('YSDAD_BUILD_DATE')`. Paramètres optionnels : `buildDate` (DateTime) pour l'imposer, `showBuildDate` (activé par défaut). Si aucune date n'est fournie, on affiche seulement la version, comme avant. L'API existante et le cadrage (`BoxFit.contain`, fond assorti) restent inchangés.

## En attente du feu vert de Patrick

- Fusion de la PR v1.4.0 (date et heure de publication à l'ouverture). Ne pas fusionner, ni recompiler, ni republier les applis sans son accord.

## Fait

- Fusion de la v1.3.0 (affichage de la version à l'ouverture), 23 novembre 2026.
