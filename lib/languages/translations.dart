import 'package:get/get.dart';
import 'package:untitled17/languages/ar.dart';
import 'package:untitled17/languages/en.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': ar,
        'en': en,
      };
}




