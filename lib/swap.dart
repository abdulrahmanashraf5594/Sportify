import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled17/pro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddProductPage(),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<PickedFile> _pickedImages = [];
  bool isLoading = false;

  bool _nameError = false;
  String _nameErrorMessage = '';
  bool _descriptionError = false;
  String _descriptionErrorMessage = '';
  bool _addressError = false;
  String _addressErrorMessage = '';
  bool _phoneError = false;
  String _phoneErrorMessage = '';

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFiles = await _picker.getMultiImage(
        maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
    setState(() {
      _pickedImages.addAll(pickedFiles!);
    });
  }

  Future<void> _uploadData() async {
    setState(() {
      isLoading = true;
      _nameError = false;
      _nameErrorMessage = '';
      _descriptionError = false;
      _descriptionErrorMessage = '';
      _addressError = false;
      _addressErrorMessage = '';
      _phoneError = false;
      _phoneErrorMessage = '';
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;

        if (_nameController.text.isEmpty ||
            _descriptionController.text.isEmpty ||
            _addressController.text.isEmpty ||
            _phoneController.text.isEmpty ||
            _pickedImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all fields and pick an image'),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        if (!_phoneController.text.startsWith('01')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone number must start with "01"'),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            isLoading = false;
            _phoneError = true;
            _phoneErrorMessage = 'Phone number must start with "01"';
          });
          return;
        }

        List<String> imageUrls = [];

        for (var pickedImage in _pickedImages) {
          final Reference storageRef = FirebaseStorage.instance.ref().child(
              'product_images/${DateTime.now()}${_pickedImages.indexOf(pickedImage)}.jpg');
          await storageRef.putFile(File(pickedImage.path));
          final String imageUrl = await storageRef.getDownloadURL();
          imageUrls.add(imageUrl);
        }

        await _firestore.collection('products').add({
          'uid': uid,
          'name': _nameController.text,
          'description': _descriptionController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'imageUrls': imageUrls,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DisplayProductsPage()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading data: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error uploading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('Add_sports_tool'.tr),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    child: PageView.builder(
                      itemCount: _pickedImages.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(_pickedImages[index].path),
                          height: 150,
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 41, 169, 92),
                      ), // Set the background color to green
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(double.infinity, 50)), // Set the minimum size
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.white, // Set the icon color to white
                        ), // // Add the image icon here
                        SizedBox(
                            width: 8), // Add space between the icon and text
                        Text(
                          'Pick_Image'.tr,
                          style: TextStyle(
                              fontSize: 17,
                              color:
                                  Colors.white), // Set the text color to white
                        ), // Button text
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: _nameError ? _nameErrorMessage : null,
                    ),
                  ),
                  SizedBox(height: 17),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText:
                          _descriptionError ? _descriptionErrorMessage : null,
                    ),
                  ),
                  SizedBox(height: 17),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'address'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: _addressError ? _addressErrorMessage : null,
                    ),
                  ),
                  SizedBox(height: 17),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(
                          11), // تحديد الحد الأقصى للأحرف
                    ],
                    decoration: InputDecoration(
                      labelText: 'phone_number'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: _phoneError ? _phoneErrorMessage : null,
                    ),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _uploadData,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 41, 169, 92),
                      ), // Set the background color to green
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(double.infinity, 50)), // Set the minimum size
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add_Tool'.tr,
                          style: TextStyle(
                              fontSize: 17,
                              color:
                                  Colors.white), // Set the text color to white
                        ), // Button text
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}