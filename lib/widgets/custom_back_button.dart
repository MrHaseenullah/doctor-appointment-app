import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

/// A custom back button that works on all platforms including web
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Use a regular IconButton for web to avoid platform-specific code
    if (kIsWeb) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: color,
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
      );
    }
    
    // Use NeumorphicBackButton for other platforms
    return NeumorphicButton(
      style: const NeumorphicStyle(
        depth: 4,
        intensity: 0.6,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Icon(
        Icons.arrow_back,
        color: color,
      ),
    );
  }
}
