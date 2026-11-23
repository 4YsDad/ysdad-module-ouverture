// Exemple complet : lib/main.dart
// Ordre : Ouverture → (À propos 1re fois, plus tard) → Connexion → Accueil
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // créé par « flutterfire configure »
import 'ysdad_about.dart'; // module À propos
import 'ysdad_connexion.dart'; // module Connexion
import 'ysdad_ouverture.dart'; // module Ouverture

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guard Focus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      // 1) Ouverture (logo Ysdad 3 s → image de l'appli 2 s)
      // La version de l'appli s'affiche en bas, automatiquement.
      home: YsdadSplash(
        appImage:
            'assets/images/logo-appli.png', // facultatif : null pour sauter
        // programmerDuration: Duration(seconds: 3),
        // appImageDuration: Duration(seconds: 2),
        // backgroundColor: Color(0xFF121212),
        // showVersion: false, // pour masquer le numéro de version
        // versionLabel: 'Version 1.0.31 (2031)', // pour imposer le libellé
        child: YsdadAuthGate(
          config: const YsdadConnexionConfig(
            appName: 'Guard Focus',
            logoAsset: 'assets/images/logo-appli.png',
          ),
          builder: (context, user) => const Accueil(),
        ),
      ),
    );
  }
}

class Accueil extends StatelessWidget {
  const Accueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guard Focus')),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text('Menu', style: TextStyle(fontSize: 24))),
            ListTile(leading: Icon(Icons.home), title: Text('Accueil')),
            Divider(),
            // Toujours en dernier dans le menu burger :
            YsdadAboutTile(appName: 'Guard Focus'),
          ],
        ),
      ),
      body: const Center(child: Text('Bienvenue!')),
    );
  }
}
