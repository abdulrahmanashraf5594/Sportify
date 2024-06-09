import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled17/pref_service.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final PrefService _prefService = PrefService();
  var sevedLang = 'en'.obs;

  saveLocale() {
    _prefService.createString('locale', sevedLang.value);
  }

  Future<void> setLocale() async {
    _prefService.readString('locale').then((value) {
      if (value != '' && value != null) {
        Get.updateLocale(Locale(value.toString().toLowerCase()));
        sevedLang.value = value.toString();
        //update();
      }
    });
  }

  @override
  void onInit() async {
    setLocale();
    super.onInit();
  }
}