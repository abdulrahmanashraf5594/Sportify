import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // لاستخدام TextInputFormatter
import 'package:cloud_firestore/cloud_firestore.dart';
class Buy extends StatefulWidget {
  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<Buy> {
  List<Color> buttonColors = [Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        backgroundColor: Color.fromARGB(255, 41, 169, 92),

        title: const Text('Payment Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Vodafone();
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: buttonColors[0],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: const Text(
                    'Electronic wallet',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Visa();
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: buttonColors[1],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: const Text(
                    'Visa',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Visa extends StatefulWidget {
  @override
  _VisaPageState createState() => _VisaPageState();
}

class _VisaPageState extends State<Visa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visa Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Card number',
                  hintText: 'XXXX-XXXX-XXXX-XXXX',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cardholder name',
                  hintText: 'الرجاء إدخال الاسم كما في البطاقة',

                  ///اكتبها انت انجليزي عشان مش متاكد منها
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        hintText: 'Month/Year',
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              InkWell(
                onTap: () {
                  ///////////////////////////
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Center(
                    child: const Text(
                      'Send',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Vodafone extends StatefulWidget {
  @override
  _VodafonePageState createState() => _VodafonePageState();
}

class _VodafonePageState extends State<Vodafone> {
  Future<List<String>> fetchPhoneNumbers() async {
    final playgrounds = FirebaseFirestore.instance.collection('playgrounds');

    final snapshot = await playgrounds.get();

    return snapshot.docs
        .where((doc) => doc.data().containsKey('phoneNumber'))
        .map<String>((doc) => doc.data()['phoneNumber'].toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vodafone Cash'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<List<String>>(
                future: fetchPhoneNumbers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final phoneNumbers = snapshot.data ?? [];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: phoneNumbers
                          .map(
                            (phoneNumber) => Text(
                          phoneNumber,
                          style: TextStyle(fontSize: 24.0),
                        ),
                      )
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 32.0),
              GestureDetector(
                onTap: () {
                  // Add your conditions for navigation here
                  // For example, check if phoneNumberError and amountError are empty
                  // before navigating to the UploadScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadScreen()),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  bool _imageSelected = false;

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imageSelected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload screenshot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: _image == null
                      ? const Center(child: Text('Tap to select image'))
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Select image',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                if (_imageSelected) {
                  print('image uploded');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Choose the image first'),
                    ),
                  );
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}