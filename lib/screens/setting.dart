import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/forgetpass.dart';
import 'package:untitled17/screens/help.dart';

import '../main.dart';
import 'about.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color appBarColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.black
        : Color.fromARGB(255, 221, 225, 231);
    Color backgroundColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[900]!
        : Color(0xffF5F5F5);
    Color textColor =
        themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    Color backButtonColor =
        themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: backButtonColor),
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
                  'Notifications',
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
                  'Dark Mode',
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
          ListTile(
            leading: Icon(Icons.language,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                size: 30.0),
            title: Text(
              'Language',
              style: TextStyle(color: textColor),
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                  print('Selected Language: $selectedLanguage');
                });
              },
              items: ['Arabic', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: textColor)),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.lock,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                size: 30.0),
            title: Text(
              'Change Password',
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPassScreen()),
              );
              // Add your navigation logic here
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
              'About',
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
              'Help',
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpScreen()),
              );
              // Add your navigation logic here
              print('Help tapped');
            },
          ),
        ],
      ),
    );
  }
}
