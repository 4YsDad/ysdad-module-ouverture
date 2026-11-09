import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ysdad_ouverture/ysdad_ouverture.dart';

void main() {
  testWidgets('logo 3 s puis l\'appli (sans image d\'appli)', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: YsdadSplash(programmerLogoAsset: kYsdadProgrammerLogoPackageAsset, child: Text('Accueil')),
    ));
    expect(find.text('Accueil'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(find.text('Accueil'), findsOneWidget);
  });
}
