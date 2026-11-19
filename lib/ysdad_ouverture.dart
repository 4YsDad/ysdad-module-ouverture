// Module « Ouverture » — Ysdad 💙
// Écran d'ouverture réutilisable : logo programmeur (3 s), puis image de l'appli (2 s).
// Voir LISEZMOI.md pour l'installation.

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Couleur de fond sombre assortie au logo Ysdad (évite le flash blanc).
/// Utile aussi comme fond uni si vous passez [YsdadSplash.backgroundColor].
const Color kYsdadSplashBackground = Color(0xFF121212);

/// Chemin d'asset du logo programmeur Ysdad (à déclarer dans pubspec.yaml).
/// Valeur par défaut, pour les applis qui ont copié le logo dans leur `assets/`.
const String kYsdadProgrammerLogoAsset = 'assets/ysdad-logo.png';

/// Logo programmeur inclus dans le paquet `ysdad_ouverture` (dépendance Git) :
/// `YsdadSplash(programmerLogoAsset: kYsdadProgrammerLogoPackageAsset, ...)`.
const String kYsdadProgrammerLogoPackageAsset =
    'packages/ysdad_ouverture/assets/ysdad-logo.png';

/// Écran d'ouverture Ysdad.
///
/// 1. Affiche le logo programmeur pendant [programmerDuration] (3 s par défaut)
///    avec un fondu doux.
/// 2. Si [appImage] est fourni et charge correctement, affiche cette image
///    pendant [appImageDuration] (2 s par défaut).
/// 3. Sinon (null ou échec de chargement), passe directement à [child]
///    (ou appelle [onFinished]) après le logo programmeur.
///
/// Chaque image occupe le plus d'espace possible, reste entière et n'est
/// jamais déformée ([BoxFit.contain]). Par défaut, l'espace restant est
/// rempli d'une version floutée et agrandie de la même image, avec un
/// léger voile sombre. Passez [backgroundColor] pour un fond uni à la place.
///
/// Ordre recommandé dans l'appli :
/// `YsdadSplash` → (popup À propos 1re ouverture) → `YsdadAuthGate` → accueil.
class YsdadSplash extends StatefulWidget {
  const YsdadSplash({
    super.key,
    required this.child,
    this.appImage,
    this.programmerLogoAsset = kYsdadProgrammerLogoAsset,
    this.programmerDuration = const Duration(seconds: 3),
    this.appImageDuration = const Duration(seconds: 2),
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 450),
    this.onFinished,
    this.logoMaxWidth = double.infinity,
  });

  /// Contenu affiché une fois l'ouverture terminée (accueil, AuthGate, etc.).
  final Widget child;

  /// Asset de l'image de l'appli (facultatif). Si null ou si le chargement
  /// échoue, on passe directement à [child] après le logo programmeur.
  final String? appImage;

  /// Asset du logo programmeur (par défaut `assets/ysdad-logo.png`).
  final String programmerLogoAsset;

  /// Durée d'affichage du logo programmeur (défaut : 3 s).
  final Duration programmerDuration;

  /// Durée d'affichage de l'image de l'appli (défaut : 2 s).
  final Duration appImageDuration;

  /// Fond uni facultatif. Si `null` (défaut), le fond est une version
  /// floutée et agrandie de l'image, avec un léger voile sombre.
  /// Exemple pour l'ancien fond uni : `backgroundColor: kYsdadSplashBackground`.
  final Color? backgroundColor;

  /// Durée du fondu entre les phases.
  final Duration fadeDuration;

  /// Appelé juste avant d'afficher [child] (facultatif).
  final VoidCallback? onFinished;

  /// Largeur max du logo / de l'image (centrés).
  /// Par défaut : aucune limite, l'image utilise toute la place disponible
  /// tout en restant entière. Passez `280` pour retrouver l'ancien cadrage.
  final double logoMaxWidth;

  @override
  State<YsdadSplash> createState() => _YsdadSplashState();
}

enum _SplashPhase { programmer, appImage, done }

class _YsdadSplashState extends State<YsdadSplash>
    with SingleTickerProviderStateMixin {
  _SplashPhase _phase = _SplashPhase.programmer;
  late final AnimationController _fade;
  late final Animation<double> _opacity;
  Timer? _timer;
  bool _appImageFailed = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: widget.fadeDuration);
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeInOut);
    _fade.forward();
    final path = widget.appImage;
    if (path == null || path.isEmpty) {
      _appImageFailed = true;
    }
    _scheduleNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    _precacheAppImage();
  }

  Future<void> _precacheAppImage() async {
    final path = widget.appImage;
    if (path == null || path.isEmpty) {
      _appImageFailed = true;
      return;
    }
    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {
      _appImageFailed = true;
    }
  }

  void _scheduleNext() {
    _timer?.cancel();
    final wait =
        _phase == _SplashPhase.programmer
            ? widget.programmerDuration
            : widget.appImageDuration;
    _timer = Timer(wait, _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted || _phase == _SplashPhase.done) return;

    if (_phase == _SplashPhase.programmer) {
      // Afficher l'image d'appli si fournie et pas en échec connu.
      // (Le préchargement accélère l'affichage; errorBuilder gère un échec tardif.)
      final showApp =
          widget.appImage != null &&
          widget.appImage!.isNotEmpty &&
          !_appImageFailed;
      if (showApp) {
        await _fadeOutIn(() {
          _phase = _SplashPhase.appImage;
        });
        if (mounted) _scheduleNext();
        return;
      }
    }

    await _finish();
  }

  Future<void> _fadeOutIn(VoidCallback changePhase) async {
    if (!mounted) return;
    await _fade.reverse();
    if (!mounted) return;
    setState(changePhase);
    await _fade.forward();
  }

  Future<void> _finish() async {
    if (!mounted || _phase == _SplashPhase.done) return;
    await _fade.reverse();
    if (!mounted) return;
    widget.onFinished?.call();
    setState(() => _phase = _SplashPhase.done);
  }

  void _onImageError() {
    if (_phase == _SplashPhase.programmer) {
      _timer?.cancel();
      _finish();
      return;
    }
    if (_phase == _SplashPhase.appImage) {
      _appImageFailed = true;
      _timer?.cancel();
      _finish();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _SplashPhase.done) {
      return widget.child;
    }

    final String asset =
        _phase == _SplashPhase.appImage
            ? widget.appImage!
            : widget.programmerLogoAsset;

    return _SplashVisual(
      asset: asset,
      opacity: _opacity,
      backgroundColor: widget.backgroundColor,
      logoMaxWidth: widget.logoMaxWidth,
      onImageError: () {
        if (mounted) _onImageError();
      },
    );
  }
}

/// Composition visuelle : fond flouté (ou couleur imposée) + image entière.
class _SplashVisual extends StatelessWidget {
  const _SplashVisual({
    required this.asset,
    required this.opacity,
    required this.backgroundColor,
    required this.logoMaxWidth,
    required this.onImageError,
  });

  final String asset;
  final Animation<double> opacity;
  final Color? backgroundColor;
  final double logoMaxWidth;
  final VoidCallback onImageError;

  @override
  Widget build(BuildContext context) {
    final fallback = backgroundColor ?? kYsdadSplashBackground;
    final useBlur = backgroundColor == null;

    return ColoredBox(
      color: fallback,
      child: FadeTransition(
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (useBlur) ...[
              _BlurredBackdrop(asset: asset),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x42000000),
                      Color(0x14000000),
                      Color(0x59000000),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ],
            _ContainedSplashImage(
              asset: asset,
              logoMaxWidth: logoMaxWidth,
              onImageError: onImageError,
            ),
          ],
        ),
      ),
    );
  }
}

/// Version floutée et agrandie de l'image, pour remplir l'écran sans
/// déformer ni rogner l'image nette du premier plan.
class _BlurredBackdrop extends StatelessWidget {
  const _BlurredBackdrop({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 48,
        sigmaY: 48,
        tileMode: TileMode.clamp,
      ),
      child: Transform.scale(
        scale: 1.2,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.low,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Image nette : [BoxFit.contain], jamais rognée ni étirée.
class _ContainedSplashImage extends StatelessWidget {
  const _ContainedSplashImage({
    required this.asset,
    required this.logoMaxWidth,
    required this.onImageError,
  });

  final String asset;
  final double logoMaxWidth;
  final VoidCallback onImageError;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      key: const Key('ysdad-ouverture-image'),
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onImageError());
        return const SizedBox.shrink();
      },
    );

    if (logoMaxWidth.isFinite) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: logoMaxWidth),
          child: image,
        ),
      );
    }

    return SizedBox.expand(child: image);
  }
}
