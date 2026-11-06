# Module « Ouverture » — Ysdad 💙

Écran d'ouverture prêt à l'emploi, le même pour toutes vos applis :
1. **Votre image de programmeur** (logo Ysdad) pendant **3 secondes**, centrée sur fond sombre (#121212), avec un fondu doux.
2. Puis **l'image de l'appli** pendant **2 secondes**, si elle est fournie.
3. Si aucune image d'appli n'est donnée (`null`) ou si elle ne charge pas → l'appli s'ouvre tout de suite après le logo programmeur.

Fonctionne sur Android, iPhone et en version web (Flutter).

## Ordre avec vos autres modules
```
YsdadSplash  →  (popup À propos 1re ouverture)  →  YsdadAuthGate  →  Accueil
   ↑ module Ouverture                              ↑ module Connexion
                      ↑ module À propos (menu burger + popup)
```

## 1. Copier 2 fichiers dans votre projet
- `lib/ysdad_ouverture.dart` → dans le dossier `lib/` du projet
- `assets/ysdad-logo.png` → dans le dossier `assets/` du projet (créez-le s'il n'existe pas)

## 2. Modifier `pubspec.yaml`
Sous `flutter:` :
```yaml
  assets:
    - assets/ysdad-logo.png
    - assets/images/logo-appli.png   # facultatif : image de VOTRE appli
```
Puis : `flutter pub get`

## 3. Utiliser le module (3 lignes)
Dans `main.dart`, enveloppez votre page d'accueil (ou `YsdadAuthGate`) :
```dart
home: YsdadSplash(
  appImage: 'assets/images/logo-appli.png', // ou null pour sauter cette étape
  child: YsdadAuthGate(                     // module Connexion
    config: const YsdadConnexionConfig(appName: 'Guard Focus'),
    builder: (context, user) => const Accueil(),
  ),
),
```
Voir `exemple_integration.dart` pour un exemple complet avec Connexion + À propos.

## Options (facultatif)
- Pas d'image d'appli : `appImage: null` (ou omettez le paramètre)
- Durées : `programmerDuration: Duration(seconds: 3)`, `appImageDuration: Duration(seconds: 2)`
- Fond : `backgroundColor: Color(0xFF121212)`
- Autre logo programmeur : `programmerLogoAsset: 'assets/autre.png'`
- Callback : `onFinished: () { ... }` (appelé juste avant d'afficher `child`)
- Taille : `logoMaxWidth: 280`

## 4. (Facultatif) Éviter le flash blanc au démarrage natif
Flutter affiche un écran natif *avant* votre `YsdadSplash`. Pour qu'il soit déjà sombre :
```
flutter pub add flutter_native_splash --dev
```
Dans `pubspec.yaml` :
```yaml
flutter_native_splash:
  color: "#121212"
  image: assets/ysdad-logo.png
  android: true
  ios: true
  web: true
```
Puis : `dart run flutter_native_splash:create`

Ce n'est **pas obligatoire** : le module fonctionne sans. Ça évite seulement un bref flash blanc avant le logo Ysdad.

## Dépendances
Aucune dépendance externe : seulement Flutter (`material.dart`).
