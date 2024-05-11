import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled17/screens/history.dart';
import 'package:untitled17/screens/home_page.dart';
import 'package:untitled17/screens/side_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'notif.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late Map<String, dynamic> userData;
  bool isLoading = true;
  var currentIndex = 3;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userData = userDoc.data() as Map<String, dynamic>;
      isLoading = false;
    });
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: userData),
      ),
    ).then((value) {
      if (value != null && value) {
        fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // عرض التحميل
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedImage =
                            await picker.getImage(source: ImageSource.gallery);

                        if (pickedImage != null) {
                          Reference ref = FirebaseStorage.instance
                              .ref()
                              .child('profile_images/${user.uid}');
                          TaskSnapshot uploadTask =
                              await ref.putFile(File(pickedImage.path));
                          String imageUrl =
                              await uploadTask.ref.getDownloadURL();

                          // Update the profileImageUrl in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'profileImageUrl': imageUrl});

                          setState(() {
                            userData['profileImageUrl'] = imageUrl;
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: userData['profileImageUrl'] != null
                                ? NetworkImage(userData['profileImageUrl'])
                                : null,
                            child: Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(top: 85, left: 85),
                              child: IconButton(
                                icon: Icon(Icons.camera_alt,
                                    color: Colors.black38),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedImage = await picker.getImage(
                                      source: ImageSource.gallery);

                                  if (pickedImage != null) {
                                    Reference ref = FirebaseStorage.instance
                                        .ref()
                                        .child('profile_images/${user.uid}');
                                    TaskSnapshot uploadTask = await ref
                                        .putFile(File(pickedImage.path));
                                    String imageUrl =
                                        await uploadTask.ref.getDownloadURL();

                                    // Update the profileImageUrl in Firestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .update({'profileImageUrl': imageUrl});

                                    setState(() {
                                      userData['profileImageUrl'] = imageUrl;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          if (userData['profileImageUrl'] ==
                              null) // عرض Loading Indicator إذا لم تكن الصورة قد تم تحميلها بعد
                            Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      title: Text('Name'),
                      subtitle: Text(userData['name'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Phone Number'),
                      subtitle: Text(userData['phone'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Birthdate'),
                      subtitle: Text(userData['birthdate'] ?? ''),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('City'),
                      subtitle: Text(userData['city'] ?? ''),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(50)),
        child: StatefulBuilder(
          builder: (context, setStateHistory) {
            return ListView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                    // Navigate to the corresponding page based on the index
                    if (index == 0) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    } else if (index == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryPage()));
                    } else if (index == 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsPage()));
                    }
                  });
                  index:
                  3;
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentIndex
                          ? displayWidth * .32
                          : displayWidth * .18,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        height: index == currentIndex ? displayWidth * .12 : 0,
                        width: index == currentIndex ? displayWidth * .32 : 0,
                        decoration: BoxDecoration(
                            color: index == currentIndex
                                ? Color.fromARGB(255, 134, 140, 143)
                                    .withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentIndex
                          ? displayWidth * .32
                          : displayWidth * .18,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayWidth * .13
                                    : 0,
                              ),
                              AnimatedOpacity(
                                opacity: index == currentIndex ? 1 : 0,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                child: Text(
                                  index == currentIndex
                                      ? '${listOfString[index]}'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayWidth * .03
                                    : 20,
                              ),
                              index == 1
                                  ? ScaleTransition(
                                      scale: CurvedAnimation(
                                          parent: AlwaysStoppedAnimation(1),
                                          curve: Curves.fastLinearToSlowEaseIn),
                                      child: Icon(
                                        listOfIcons[index],
                                        size: displayWidth * .076,
                                        color: index == currentIndex
                                            ? Colors.black87
                                            : Colors.black26,
                                      ),
                                    )
                                  : Icon(
                                      listOfIcons[index],
                                      size: displayWidth * .076,
                                      color: index == currentIndex
                                          ? Colors.black87
                                          : Colors.black26,
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> listOfString = [
    'Home',
    'History',
    'Notification',
    'Profile',
  ];

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_active,
    Icons.person_rounded,
  ];
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _birthdateController =
        TextEditingController(text: widget.userData['birthdate']);
    _cityController = TextEditingController(text: widget.userData['city']);
  }

  Future<void> _saveChanges() async {
    try {
      // Save updated profile data to Firestore
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.doc('users/$userId').update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'birthdate': _birthdateController.text,
        'city': _cityController.text,
      });

      // Return true to indicate successful save
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving changes: $e');
      // Return false to indicate unsuccessful save
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: 'Birthdate'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null && pickedDate != DateTime.now()) {
                  setState(() {
                    _birthdateController.text =
                        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                  });
                }
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 41, 169, 92), // لون الزر
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
