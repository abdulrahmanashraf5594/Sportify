import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/constants.dart';
import 'package:untitled17/forgetpass.dart';
import 'package:untitled17/screens/help.dart';

import '../languages/language_controller.dart';
import '../main.dart';
import 'about.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'Arabic';

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr,
        ),
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: textColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  'notifications'.tr,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: Row(
              children: [
                Icon(
                  Icons.dark_mode,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  'dark_mode'.tr,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider
                  .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          GetBuilder<LanguageController>(
              init: LanguageController(),
              builder: (controller) {
                return ListTile(
                  leading: Icon(Icons.language,
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      size: 30.0),
                  title: Text(
                    'language'.tr,
                    style: TextStyle(color: textColor),
                  ),
                  trailing: DropdownButton<String>(
                    value: selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.sevedLang.value = newValue;
                        Locale locale = Locale(
                            newValue.toLowerCase() == 'Arabic' ? 'ar' : 'en');
                        controller.saveLocale();
                        Get.updateLocale(locale);
                        setState(() {
                          selectedLanguage = newValue;
                        });
                      }
                    },
                    items: ['Arabic', 'English']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                  ),
                );
              }),
          ListTile(
            leading: Icon(Icons.lock,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                size: 30.0),
            title: Text(
              'change_password'.tr,
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPassScreen()),
              );
              print('Change Password tapped');
            },
          ),
          ListTile(
            leading: Icon(Icons.info,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                size: 30.0),
            title: Text(
              'about'.tr,
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
              print('About tapped');
            },
          ),
          ListTile(
            leading: Icon(Icons.help,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                size: 30.0),
            title: Text(
              'help'.tr,
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpScreen()),
              );
              print('Help tapped');
            },
          ),
        ],
      ),
    );
  }
}
