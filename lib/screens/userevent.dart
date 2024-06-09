import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SubscribersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('Event Subscribers'.tr),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('event_subscribers_null'.tr)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'.tr),
            );
          } else {
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No subscribers found.'.tr),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> subscriberData =
                    document.data()! as Map<String, dynamic>;

                if (currentUser != null &&
                    subscriberData['userId'] == currentUser.uid) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        'Name: ${subscriberData['name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          _buildInfoRow(
                              Icons.phone, '${subscriberData['phone']}'),
                          _buildInfoRow(
                              Icons.person, '${subscriberData['gender']}'),
                          _buildInfoRow(Icons.cake, '${subscriberData['age']}'),
                          _buildInfoRow(Icons.account_circle,
                              '${subscriberData['userId']}'),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditUserProfileScreen(
                                      userData: subscriberData),
                                ),
                              );
                            },
                            child: Text('Edit'),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _unsubscribeFromEvent(
                                  currentUser.uid, document.id);
                              Navigator.pop(context);
                            },
                            child: Text('Unsubscribe'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center();
                }
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _unsubscribeFromEvent(String userId, String eventId) {
    FirebaseFirestore.instance
        .collection('event_subscribers_null')
        .doc(eventId)
        .collection('subscribers')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      // Delete the document from the main collection after removing from subscribers collection
      FirebaseFirestore.instance
          .collection('event_subscribers_null')
          .doc(eventId)
          .delete()
          .then((value) => print("Unsubscribed successfully"))
          .catchError((error) => print("Failed to unsubscribe: $error"));
    }).catchError((error) => print("Failed to unsubscribe: $error"));
  }
}

class EditUserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditUserProfileScreen({required this.userData});

  @override
  _EditUserProfileScreenState createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'];
    _phoneController.text = widget.userData['phone'];
    _genderController.text = widget.userData['gender'];
    _ageController.text = widget.userData['age'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        backgroundColor: Color.fromARGB(255, 41, 169, 92),

        title: Text('Edit User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveUserData();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUserData() {
    Map<String, dynamic> updatedUserData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'gender': _genderController.text,
      'age': _ageController.text,
    };

    // Update user data in Firebase
    FirebaseFirestore.instance
        .collection('event_subscribers_null')
        .doc(widget.userData['eventId'])
        .collection('subscribers')
        .doc(widget.userData['userId'])
        .update(updatedUserData)
        .then((value) => Navigator.pop(context))
        .catchError((error) => print("Failed to update user data: $error"));
  }
}
