import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true);
  
  for (final file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      final updatedContent = content.replaceAll(
        "import 'package:flutter_neumorphic/flutter_neumorphic.dart';",
        "import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';"
      );
      
      if (content != updatedContent) {
        file.writeAsStringSync(updatedContent);
        print('Updated imports in ${file.path}');
      }
    }
  }
  
  print('Done updating imports!');
}
