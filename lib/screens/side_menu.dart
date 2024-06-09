import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled17/screens/setting.dart';
import 'package:untitled17/screens/userevent.dart';

import '../fav.dart';
import '../profhome.dart';
import 'betriner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckUserPage(),
    );
  }
}

class CheckUserPage extends StatelessWidget {
  const CheckUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUser(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.data != null && snapshot.data!) {
            // المستخدم مسجل بياناته في كولكشن المدربين في فايربيس
            return TrainerHomePage();
          } else {
            // المستخدم ليس لديه بيانات في كولكشن المدربين في فايربيس
            return TrainerResPage();
          }
        }
      },
    );
  }

  Future<bool> checkUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // قم بفحص ما إذا كان لديك بيانات للمستخدم في كولكشن المدربين في فايربيس
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('trainers')
            .doc(user.uid)
            .get();

        // إذا كان هناك بيانات للمستخدم، فهو مسجل في كولكشن المدربين
        return userData.exists;
      }

      return false;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 55, 55, 55),
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(
                'SPORTIFY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'images/spooooortttt.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 55, 55, 55),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            _buildMenuItem('beATrainer'.tr, Icons.group_add, () async {
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                try {
                  DocumentSnapshot userData = await FirebaseFirestore.instance
                      .collection('approved_trainers')
                      .doc(user.uid)
                      .get();

                  // Check if user data exists
                  if (userData.exists) {
                    // If data exists, navigate to TrainerHomePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrainerHomePage()),
                    );
                  } else {
                    // If data doesn't exist, navigate to TrainerResPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrainerResPage()),
                    );
                  }
                } catch (e) {
                  // Print error message for debugging
                  print('Error checking user: $e');
                }
              }
            }),
            _buildMenuItem('settings'.tr, Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }),
            _buildMenuItem('profile'.tr, Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }),
            _buildMenuItem('history'.tr, Icons.history_rounded, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscribersPage()),
              );
            }),
            Spacer(),
            const Divider(
              color: Colors.white,
            ),
            _buildMenuItem('logOut'.tr, Icons.logout, () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }),
            _buildMenuItem('trainer'.tr, Icons.accessibility_sharp, () {
              // طلب كلمة المرور
              _requestPassword(context, () {
                // عند التحقق من صحة كلمة المرور، قم بفتح الصفحة
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainerHomePage()),
                );
              });
            }),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  void _requestPassword(BuildContext context, Function onPasswordVerified) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String enteredPassword = '';
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
            decoration: InputDecoration(hintText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // التحقق من صحة كلمة المرور
                if (enteredPassword == '123456') {
                  Navigator.of(context).pop();
                  onPasswordVerified(); // تنفيذ العملية عندما تكون كلمة المرور صحيحة
                } else {
                  // إعلام المستخدم بأن كلمة المرور غير صحيحة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect password. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Page'),
      ),
      body: const Center(
        child: Text('Setting Page Content'),
      ),
    );
  }
}
