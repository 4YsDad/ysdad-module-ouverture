# À faire — module Ouverture

## Décisions

- 23 novembre 2026 : afficher le numéro de version de l'appli en bas de l'écran d'ouverture, dès le logo Ysdad et pendant l'image de l'appli. Texte petit, discret mais lisible, centré en bas, contrastant avec le fond (ex. « Version 1.0.31 (2031) »). Récupération automatique via `package_info_plus`, avec possibilité de passer le libellé (`versionLabel`) ou de masquer l'affichage (`showVersion: false`). Affichage activé par défaut. L'API existante et le cadrage (`BoxFit.contain`, fond assorti) restent inchangés.

## En attente du feu vert de Patrick

- Fusion de la PR v1.3.0 (affichage de la version à l'ouverture). Ne pas fusionner, ni recompiler, ni republier les applis sans son accord.
