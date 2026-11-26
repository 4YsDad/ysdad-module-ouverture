// Module « Ouverture » — Ysdad 💙
// Écran d'ouverture réutilisable : logo programmeur (3 s), puis image de l'appli (2 s).
// Voir LISEZMOI.md pour l'installation.

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

/// Construit le libellé affiché, ex. « Version 1.0.31 (2031) ».
///
/// Retourne `null` si la version et le numéro de compilation sont vides.
String? ysdadFormatVersionLabel({
  required String version,
  required String buildNumber,
}) {
  final v = version.trim();
  final b = buildNumber.trim();
  if (v.isEmpty && b.isEmpty) return null;
  if (v.isEmpty) return 'Version $b';
  if (b.isEmpty) return 'Version $v';
  return 'Version $v ($b)';
}

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
/// Le numéro de version de l'appli s'affiche en bas de l'écran, dès le logo
/// Ysdad et pendant l'image de l'appli (ex. « Version 1.0.31 (2031) »).
/// Il est lu automatiquement ; vous pouvez aussi le passer avec
/// [versionLabel] ou le masquer avec [showVersion] (activé par défaut).
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
    this.showVersion = true,
    this.versionLabel,
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

  /// Affiche le numéro de version en bas de l'écran d'ouverture (défaut : oui).
  final bool showVersion;

  /// Libellé de version à afficher tel quel, ex. « Version 1.0.31 (2031) ».
  /// Si `null` (défaut) et que [showVersion] est vrai, le module lit
  /// automatiquement la version de l'appli.
  final String? versionLabel;

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
  String? _versionLabel;

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
    _resolveVersionLabel();
    _scheduleNext();
  }

  void _resolveVersionLabel() {
    if (!widget.showVersion) {
      _versionLabel = null;
      return;
    }
    final provided = widget.versionLabel?.trim();
    if (provided != null && provided.isNotEmpty) {
      _versionLabel = provided;
      return;
    }
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted || !widget.showVersion) return;
      final label = ysdadFormatVersionLabel(
        version: info.version,
        buildNumber: info.buildNumber,
      );
      if (label == null || label == _versionLabel) return;
      setState(() => _versionLabel = label);
    } catch (_) {
      // Si la version ne peut pas être lue, on n'affiche rien.
    }
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
      versionLabel: widget.showVersion ? _versionLabel : null,
      onImageError: () {
        if (mounted) _onImageError();
      },
    );
  }
}

/// Composition visuelle : fond flouté (ou couleur imposée) + image entière
/// + numéro de version centré en bas, hors du fondu pour qu'il reste stable.
class _SplashVisual extends StatelessWidget {
  const _SplashVisual({
    required this.asset,
    required this.opacity,
    required this.backgroundColor,
    required this.logoMaxWidth,
    required this.onImageError,
    this.versionLabel,
  });

  final String asset;
  final Animation<double> opacity;
  final Color? backgroundColor;
  final double logoMaxWidth;
  final VoidCallback onImageError;
  final String? versionLabel;

  @override
  Widget build(BuildContext context) {
    final fallback = backgroundColor ?? kYsdadSplashBackground;
    final useBlur = backgroundColor == null;

    return ColoredBox(
      color: fallback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
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
          if (versionLabel != null && versionLabel!.isNotEmpty)
            _SplashVersionLabel(
              label: versionLabel!,
              backgroundColor: backgroundColor,
              useBlur: useBlur,
            ),
        ],
      ),
    );
  }
}

/// Petit libellé de version, centré en bas, discret mais lisible.
class _SplashVersionLabel extends StatelessWidget {
  const _SplashVersionLabel({
    required this.label,
    required this.backgroundColor,
    required this.useBlur,
  });

  final String label;
  final Color? backgroundColor;
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    final isDark =
        useBlur ||
        (backgroundColor ?? kYsdadSplashBackground).computeLuminance() < 0.45;
    final textColor = isDark ? Colors.white : const Color(0xDE000000);
    final shadowColor =
        isDark ? const Color(0xCC000000) : const Color(0xCCFFFFFF);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IgnorePointer(
            child: Text(
              label,
              key: const Key('ysdad-ouverture-version'),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: textColor.withValues(alpha: 0.92),
                shadows: [
                  Shadow(color: shadowColor, blurRadius: 8),
                  Shadow(color: shadowColor, blurRadius: 2),
                ],
              ),
            ),
          ),
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
