import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled17/events.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  List<File> _selectedImages = [];
  String? _selectedEventType;
  String? _phoneNumber;
  String? _eventLocation;
  String? _description;
  String? _ageRangeFrom;
  String? _ageRangeTo;
  bool? _fee;
  bool? _insurance;
  bool? _haveBike;
  double? _distance;
  bool _isLoading = false;
  TextEditingController _startLocationController = TextEditingController();
  TextEditingController _endLocationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await ImagePicker().pickMultiImage(
        maxWidth: 800,
        imageQuality: 80,
      );

      if (images != null) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  void _addEventToFirestore() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      CollectionReference events =
          FirebaseFirestore.instance.collection('events');

      List<String> imageUrls = await _uploadImages(_selectedImages);

      events.add({
        'eventName': _eventLocation,
        'phoneNumber': _phoneNumber,
        'distance': _distance,
        'description': _description,
        'ageRangeFrom': _ageRangeFrom,
        'ageRangeTo': _ageRangeTo,
        'fee': _fee,
        'insurance': _insurance,
        'haveBike': _haveBike,
        'eventType': _selectedEventType,
        'images': imageUrls,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'date': DateTime.now(),
        'startLocationMapLink': _startLocationController.text.trim(),
        'endLocationMapLink': _endLocationController.text.trim(),
      }).then((value) {
        print("Event added with ID: ${value.id}");
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages.clear();
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content:
                  Text("Your event has been submitted and will be reviewed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EventList()),
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        print("Failed to add event: $error");
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: _pickImages,
                        child: Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: _selectedImages.isEmpty
                              ? Center(child: Text('Add Image'))
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 200,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Event Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 41, 169, 92),
                            ), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _eventLocation = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event location';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 41, 169, 92),
                            ), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            _phoneNumber = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedEventType,
                        decoration: InputDecoration(
                          labelText: 'Select Event Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.blue), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedEventType = value;
                            _ageRangeFrom = null;
                            _ageRangeTo = null;
                            _fee = null;
                            _insurance = null;
                            _haveBike = null;
                            _distance = null;
                          });
                        },
                        items: <String>[
                          'Cycling Event',
                          'Running Event',
                          'Others'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      if (_selectedEventType == 'Others') ...[
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Other Sport',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // تطبيق حروف دائرية
                              borderSide:
                                  BorderSide(color: Colors.grey), // لون الحدود
                            ),
                            filled: true, // تفعيل اللون الخلفي للحقل
                            fillColor: Colors.grey[200], // لون خلفية الحقل
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 41, 169, 92),
                              ), // لون الحدود عند التركيز
                            ),
                            // تطبيق ظل عند التركيز
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            // تطبيق ظل عند وجود خطأ
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            // نص خطأ
                            errorStyle: TextStyle(color: Colors.red),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedEventType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter other sport';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (_selectedEventType == 'Cycling Event' ||
                          _selectedEventType == 'Running Event') ...[
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Age Range From',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // تطبيق حروف دائرية
                                    borderSide: BorderSide(
                                        color: Colors.grey), // لون الحدود
                                  ),
                                  filled: true, // تفعيل اللون الخلفي للحقل
                                  fillColor:
                                      Colors.grey[200], // لون خلفية الحقل
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 41, 169, 92),
                                    ), // لون الحدود عند التركيز
                                  ),
                                  // تطبيق ظل عند التركيز
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // تطبيق ظل عند وجود خطأ
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // نص خطأ
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _ageRangeFrom = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Age Range To',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // تطبيق حروف دائرية
                                    borderSide: BorderSide(
                                        color: Colors.grey), // لون الحدود
                                  ),
                                  filled: true, // تفعيل اللون الخلفي للحقل
                                  fillColor:
                                      Colors.grey[200], // لون خلفية الحقل
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 41, 169, 92),
                                    ), // لون الحدود عند التركيز
                                  ),
                                  // تطبيق ظل عند التركيز
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // تطبيق ظل عند وجود خطأ
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // نص خطأ
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _ageRangeTo = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                decoration: InputDecoration(
                                  labelText: 'Fee',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // تطبيق حروف دائرية
                                    borderSide: BorderSide(
                                        color: Colors.grey), // لون الحدود
                                  ),
                                  filled: true, // تفعيل اللون الخلفي للحقل
                                  fillColor:
                                      Colors.grey[200], // لون خلفية الحقل
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 41, 169, 92),
                                    ), // لون الحدود عند التركيز
                                  ),
                                  // تطبيق ظل عند التركيز
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // تطبيق ظل عند وجود خطأ
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // نص خطأ
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                value: _fee,
                                onChanged: (value) {
                                  setState(() {
                                    _fee = value;
                                  });
                                },
                                items: <bool?>[true, false]
                                    .map<DropdownMenuItem<bool>>(
                                  (bool? value) {
                                    return DropdownMenuItem<bool>(
                                      value: value,
                                      child: Text(value == true ? 'Yes' : 'No'),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                decoration: InputDecoration(
                                  labelText: 'Insurance',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // تطبيق حروف دائرية
                                    borderSide: BorderSide(
                                        color: Colors.grey), // لون الحدود
                                  ),
                                  filled: true, // تفعيل اللون الخلفي للحقل
                                  fillColor:
                                      Colors.grey[200], // لون خلفية الحقل
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 41, 169, 92),
                                    ), // لون الحدود عند التركيز
                                  ),
                                  // تطبيق ظل عند التركيز
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // تطبيق ظل عند وجود خطأ
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // نص خطأ
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                value: _insurance,
                                onChanged: (value) {
                                  setState(() {
                                    _insurance = value;
                                  });
                                },
                                items: <bool?>[true, false]
                                    .map<DropdownMenuItem<bool>>(
                                  (bool? value) {
                                    return DropdownMenuItem<bool>(
                                      value: value,
                                      child: Text(value == true ? 'Yes' : 'No'),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedEventType == 'Cycling Event') ...[
                          SizedBox(height: 20),
                          DropdownButtonFormField<bool>(
                            decoration: InputDecoration(
                              labelText: 'Do you have a bike?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // تطبيق حروف دائرية
                                borderSide: BorderSide(
                                    color: Colors.grey), // لون الحدود
                              ),
                              filled: true, // تفعيل اللون الخلفي للحقل
                              fillColor: Colors.grey[200], // لون خلفية الحقل
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 41, 169, 92),
                                ), // لون الحدود عند التركيز
                              ),
                              // تطبيق ظل عند التركيز
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              // تطبيق ظل عند وجود خطأ
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              // نص خطأ
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                            value: _haveBike,
                            onChanged: (value) {
                              setState(() {
                                _haveBike = value;
                              });
                            },
                            items: <bool?>[true, false]
                                .map<DropdownMenuItem<bool>>(
                              (bool? value) {
                                return DropdownMenuItem<bool>(
                                  value: value,
                                  child: Text(value == true ? 'Yes' : 'No'),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ],
                      if (_selectedEventType == 'Running Event') ...[
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Distance (in kilometers)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // تطبيق حروف دائرية
                                    borderSide: BorderSide(
                                        color: Colors.grey), // لون الحدود
                                  ),
                                  filled: true, // تفعيل اللون الخلفي للحقل
                                  fillColor:
                                      Colors.grey[200], // لون خلفية الحقل
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 41, 169, 92),
                                    ), // لون الحدود عند التركيز
                                  ),
                                  // تطبيق ظل عند التركيز
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // تطبيق ظل عند وجود خطأ
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  // نص خطأ
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _distance = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 41, 169, 92),
                            ), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _startLocationController,
                        decoration: InputDecoration(
                          labelText: 'Start Location (Google Maps Link)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 41, 169, 92),
                            ), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter start location';
                          }
                          if (!(value.startsWith('https://maps.google.com') ||
                              value.startsWith('https://maps.app.goo.gl'))) {
                            return 'Please enter a valid Google Maps link';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _endLocationController,
                        decoration: InputDecoration(
                          labelText: 'End Location (Google Maps Link)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // تطبيق حروف دائرية
                            borderSide:
                                BorderSide(color: Colors.grey), // لون الحدود
                          ),
                          filled: true, // تفعيل اللون الخلفي للحقل
                          fillColor: Colors.grey[200], // لون خلفية الحقل
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 41, 169, 92),
                            ), // لون الحدود عند التركيز
                          ),
                          // تطبيق ظل عند التركيز
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // تطبيق ظل عند وجود خطأ
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          // نص خطأ
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter end location';
                          }
                          if (!(value.startsWith('https://maps.google.com') ||
                              value.startsWith('https://maps.app.goo.gl'))) {
                            return 'Please enter a valid Google Maps link';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addEventToFirestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 41, 169, 92),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Add Event',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
