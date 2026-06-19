import 'package:flutter/material.dart';
import 'package:flutter_3d_carousel/flutter_3d_carousel.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../commondesign/common_wave_design.dart';

const List<String> _carouselImages = [
  'assets/images/pic1.png',
  'assets/images/pic2.png',
  'assets/images/pic3.png',
  'assets/images/pic4.png',
  'assets/images/pic5.png',
  'assets/images/pic6.png',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login();
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed('/designs');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final carouselHeight = (constraints.maxHeight * 0.32)
              .clamp(220.0, 310.0)
              .toDouble();
          final carouselImageWidth = screenWidth * 0.70;

          return Stack(
            fit: StackFit.expand,
            children: [
              const CommonWaveDesign(),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 88),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GRAVITY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.8,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Configurator',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFE94560),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.29,
                left: 0,
                right: 0,
                height: carouselHeight,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: CarouselWidget3D(
                    radius: screenWidth,
                    childScale: 0.9,
                    dragEndBehavior: DragEndBehavior.snapToNearest,
                    backgroundTapBehavior:
                        BackgroundTapBehavior.startAndSnapToNearest,
                    childTapBehavior: ChildTapBehavior.transparent,
                    isDragInteractive: true,
                    onlyRenderForeground: false,
                    clockwise: false,
                    backgroundBlur: 3,
                    spinWhileRotating: true,
                    shouldRotate: true,
                    timeForFullRevolution: 20000,
                    snapTimeInMillis: 100,
                    perspectiveStrength: 0.001,
                    dragSensitivity: 1.0,
                    onValueChanged: (newValue) {
                      debugPrint('$newValue');
                    },
                    background: null,
                    core: null,
                    children: List.generate(
                      _carouselImages.length,
                      (index) => CarouselChild(
                        child: SizedBox(
                          width: carouselImageWidth,
                          height: carouselHeight,
                          child: Image.asset(
                            _carouselImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 60,
                right: 60,
                bottom: constraints.maxHeight * 0.27,
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isLoading = auth.status == AuthStatus.loading;
                        return SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _handleGetStarted(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.accentColor.withAlpha(128),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
