import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_background.dart';
import '../widgets/insurex_logo.dart';
import '../widgets/splash_actions.dart';
import '../widgets/splash_brand.dart';
import '../widgets/splash_description_card.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0,
        0.82,
        curve: Curves.easeIn,
      ),
    );

    _logoScaleAnimation =
        Tween<double>(
          begin: 0.78,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              final double logoSize =
              (constraints.maxHeight * 0.27).clamp(
                190.0,
                235.0,
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 430,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: <Widget>[
                                const SplashBrand(),
                                const SizedBox(height: 25),
                                ScaleTransition(
                                  scale: _logoScaleAnimation,
                                  child: InsureXLogo(
                                    size: logoSize,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const SplashDescriptionCard(),
                                const SizedBox(height: 25),
                                SplashActions(
                                  onGetStarted:
                                  widget.onGetStarted,
                                  onLogin: widget.onLogin,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}