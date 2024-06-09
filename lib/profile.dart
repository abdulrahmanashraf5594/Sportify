import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled17/screens/home_page.dart';

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;

  String _gender = 'Male'; // Default 'Male'

  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _loading = false;
  String _imageUrl = ''; // Variable to store the image URL

  TextEditingController _dayController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = TextEditingController();

    // Fetch user data when the page opens
    _fetchUserData();
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userData =
          await _firestore.doc('users/$userId').get();

      if (userData.exists) {
        Map<String, dynamic> data = userData.data()!;
        _nameController.text = data['name'];
        _cityController.text = data['city'];
        _gender = data['gender'];
        _phoneController.text = data['phone'];

        // Set the birthdate fields
        List<String> birthdate = data['birthdate'].split('/');
        _dayController.text = birthdate[0];
        _monthController.text = birthdate[1];
        _yearController.text = birthdate[2];
        _imageUrl = data['profileImageUrl'];
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      // Hide Loading
      setState(() {
        _loading = false;
      });
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // Remove the call to uploadImage here, it will be called when saving the profile
      }
    });
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      try {
        String userId = _auth.currentUser!.uid;
        Reference ref = _storage.ref().child('profile_images/$userId.jpg');
        UploadTask uploadTask = ref.putFile(_image!);
        await uploadTask.whenComplete(() => null);
        String downloadUrl = await ref.getDownloadURL();

        // Save the download URL to the _imageUrl variable
        _imageUrl = downloadUrl;

        // Print the image URL for verification
        print('Image uploaded. Download URL: $_imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> saveProfile() async {
    try {
      // Show Loading
      setState(() {
        _loading = true;
      });

      await uploadImage();

      // Save other profile data to Firestore
      String userId = _auth.currentUser!.uid;
      await _firestore.doc('users/$userId').set({
        'name': _nameController.text,
        'city': _cityController.text,
        'gender': _gender,
        'birthdate':
            '${_dayController.text}/${_monthController.text}/${_yearController.text}',
        'phone': _phoneController.text,
        'profileImageUrl': _imageUrl,
      });

      print('Profile saved successfully.');

      // Navigate to HomePage after successful save
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      // Hide Loading
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dayController.text = pickedDate.day.toString();
        _monthController.text = pickedDate.month.toString();
        _yearController.text = pickedDate.year.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor:
                    Colors.grey[200], // لإضافة لون خلفية لل CircleAvatar
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 40,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (String? value) {
                setState(() {
                  _gender = value!;
                });
              },
              items: ['Male', 'Female']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(labelText: 'Gender'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dayController,
                        decoration: InputDecoration(labelText: 'Day'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the day of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _monthController,
                        decoration: InputDecoration(labelText: 'Month'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the month of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the year of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please select a profile picture'),
                  ));
                } else {
                  if (_nameController.text.isEmpty ||
                      _cityController.text.isEmpty ||
                      _gender.isEmpty ||
                      _dayController.text.isEmpty ||
                      _monthController.text.isEmpty ||
                      _yearController.text.isEmpty ||
                      _phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please fill in all the fields'),
                    ));
                  } else {
                    saveProfile();
                  }
                }
              },
              child:
                  _loading ? CircularProgressIndicator() : Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
