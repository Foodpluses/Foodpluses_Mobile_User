import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/images.dart';

class AnimatedSplashWidget extends StatelessWidget {
  const AnimatedSplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // Whitish gray background
      child: Center(
        child: Image.asset(
          Images.splashIcon,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          gaplessPlayback: true, // This ensures the GIF plays once
        ),
      ),
    );
  }
}

