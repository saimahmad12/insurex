import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({
    super.key,
    this.size = 27,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Google logo',
      child: Image.asset(
        AppAssets.googleGLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
            ) {
          return Icon(
            Icons.language_rounded,
            size: size,
            color: Colors.white,
          );
        },
      ),
    );
  }
}