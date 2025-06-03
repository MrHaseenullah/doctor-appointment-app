import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'custom_back_button.dart';

/// A custom app bar that works on all platforms including web
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    // Use a regular AppBar for web to avoid platform-specific code
    if (kIsWeb) {
      return AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? const Color(0xFFE0E5EC),
        leading: leading ?? (automaticallyImplyLeading ? const CustomBackButton() : null),
        elevation: 0,
      );
    }
    
    // Use NeumorphicAppBar for other platforms
    return NeumorphicAppBar(
      title: Text(title),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      color: backgroundColor,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
