import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TrainerResPage extends StatefulWidget {
  @override
  _TrainerResPageState createState() => _TrainerResPageState();
}

class _TrainerResPageState extends State<TrainerResPage> {
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _twitterController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();
  TextEditingController _youtubeController = TextEditingController();
  TextEditingController _linkedinController = TextEditingController();
  String _selectedSport = 'football'.tr; // Default sport

  File? _profileImage;
  File? _idImage;
  File? _pdfFile;
  List<File?> _certificatesImages = List.generate(8, (index) => null);

  Widget _buildUploadButton(
      String buttonText, VoidCallback onPressed, IconData icon) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 41, 169, 92), // لون الزر
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      icon: Icon(
        icon,
        color: Colors.white,
      ), // أيقونة الزر
      label: Text(
        buttonText,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _idImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCertificateImages() async {
    List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _certificatesImages =
            pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _pickPdf() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pdfFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitData() async {
    try {
      setState(() {
        _isLoading = true; // تفعيل حالة التحميل
      });

      User? user = _auth.currentUser;
      if (user != null) {
        // Check if the user has already submitted data
        DocumentSnapshot userData =
            await _firestore.collection('trainer_requests').doc(user.uid).get();

        if (userData.exists) {
          // If user is already registered as a trainer, open the trainer's page directly
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerHomePage(),
            ),
          );
        } else {
          // Upload images to Firebase Storage
          String profileImageUrl =
              await _uploadImage(_profileImage, 'profile_images');
          String idImageUrl = await _uploadImage(_idImage, 'id_images');
          List<String> certificatesImageUrls = await Future.wait(
            _certificatesImages
                .map((image) => _uploadImage(image, 'certificates_images'))
                .toList(),
          );

          // Upload PDF to Firebase Storage
          String pdfUrl = await _uploadPdf(_pdfFile);

          // Save trainer data to Firestore with acceptance status as 'Pending'
          String trainerUID = user.uid; // معرف المدرب
          await _firestore.collection('trainer_requests').doc(trainerUID).set({
            'profileImage': profileImageUrl,
            'name': _nameController.text,
            'age': int.parse(_ageController.text),
            'number': int.parse(_numberController.text),
            'address': _addressController.text,
            'experience': int.parse(_experienceController.text),
            'sport': _selectedSport,
            'idImage': idImageUrl,
            'certificatesImages': certificatesImageUrls,
            'pdf': pdfUrl,
            'status': 'Pending', // حالة القبول
            'facebook': _facebookController.text,
            'twitter': _twitterController.text,
            'instagram': _instagramController.text,
            'youtube': _youtubeController.text,
            'linkedin': _linkedinController.text,
            'trainerUID': trainerUID, // معرف المدرب
          });

          // Navigate to a new page after data submission
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerHomePage(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error submitting data: $e');
      // Handle error (show error message, etc.)
    } finally {
      setState(() {
        _isLoading =
            false; // تعطيل حالة التحميل بغض النظر عن نجاح أو فشل العملية
      });
    }
  }

  Future<String> _uploadImage(File? image, String folder) async {
    try {
      if (image != null) {
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('$folder/$imageName');
        UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);
        return await storageReference.getDownloadURL();
      } else {
        throw Exception('Image file is null.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> _uploadPdf(File? pdf) async {
    try {
      if (pdf != null) {
        String pdfName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('pdfs/$pdfName');
        UploadTask uploadTask = storageReference.putFile(pdf);
        await uploadTask.whenComplete(() => null);
        return await storageReference.getDownloadURL();
      } else {
        throw Exception('PDF file is null.');
      }
    } catch (e) {
      print('Error uploading PDF: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('Trainer_Resources'.tr),
      ),
      body: _isLoading // شاشة التحميل
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload_Profile_Image'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildUploadButton(
                      'Pick_Profile_Image'.tr,
                      _pickProfileImage,
                      Icons.image,
                    ),
                    if (_profileImage != null) Image.file(_profileImage!),
                    SizedBox(height: 20),
                    // البيانات الشخصية
                    Text(
                      'Personal_Information'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full_Name'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'age'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'phone_number'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'address'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),

                    SizedBox(height: 20),
                    // الخبرة
                    Text(
                      'experience'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Experience_(years)'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),

                    SizedBox(height: 20),
                    // وسائل التواصل الاجتماعي
                    Text(
                      'Social_Media'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _facebookController,
                      decoration: InputDecoration(
                        labelText: 'facebook'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _twitterController,
                      decoration: InputDecoration(
                        labelText: 'twitter'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _instagramController,
                      decoration: InputDecoration(
                        labelText: 'instagram'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _youtubeController,
                      decoration: InputDecoration(
                        labelText: 'youtube'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _linkedinController,
                      decoration: InputDecoration(
                        labelText: 'linkedIn'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),

                    SizedBox(height: 20),
                    // الرياضة
                    Text(
                      'sport'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedSport,
                      decoration: InputDecoration(
                        labelText: 'sport'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: false,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 41, 169, 92),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      items: [
                        'football'.tr,
                        'swimming'.tr,
                        'badminton'.tr,
                        'gym'.tr,
                        'Combat_Games'.tr
                      ].map((sport) {
                        return DropdownMenuItem<String>(
                          value: sport,
                          child: Text(sport),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSport = value!;
                        });
                      },
                    ),

                    SizedBox(height: 20),
                    // صورة الهوية
                    Text(
                      'Upload_ID_Image'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _idImage != null
                        ? Image.file(
                            _idImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadButton(
                            'Choose_Image'.tr,
                            () => _pickImage(
                              ImageSource.gallery,
                            ),
                            Icons.photo,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildUploadButton(
                            'Take_Photo'.tr,
                            () => _pickImage(ImageSource.camera),
                            Icons.camera_alt,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // صور الشهادات
                    Text(
                      'Upload_Certificates_Images'.tr,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildUploadButton(
                      'Pick_Certificates_Images'.tr,
                      _pickCertificateImages,
                      Icons.image,
                    ),
                    for (int i = 0; i < _certificatesImages.length; i++)
                      if (_certificatesImages[i] != null)
                        Image.file(_certificatesImages[i]!),
                    SizedBox(height: 10),
                    // ملف PDF
                    _pdfFile != null ? Text(_pdfFile!.path) : Container(),
                    _buildUploadButton(
                      'Choose_PDF'.tr,
                      _pickPdf,
                      Icons.picture_as_pdf,
                    ),
                    SizedBox(height: 20),
                    // زر الإرسال
                    _buildUploadButton(
                      'submit'.tr,
                      _submitData,
                      Icons.send,
                    ),
                  ],
                ),
              ),
            ),
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
            .collection('trainer_requests')
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

class TrainerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('Trainer Home Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('coach_bookings').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something_went_wrong'.tr);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> request =
                  document.data() as Map<String, dynamic>;
              return RequestCard(request: request);
            }).toList(),
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    // Extracting day, month, and year from the 'date' field in the request map
    String day = request['date'].toDate().day.toString();
    String month = request['date'].toDate().month.toString();
    String year = request['date'].toDate().year.toString();

    return Card(
      color: Colors.grey[200],
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(request['image_url'] ??
                  'https://example.com/default-profile-image.jpg'),
              radius: 50,
            ),
            SizedBox(height: 10),

            // Displaying the date in an organized manner
            Text(
              'date: $day-$month-$year',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              'End Time: ${request['end_time']}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              'Start Time: ${request['start_time'] ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _acceptRequest(
                      context,
                      request['userId'],
                      request['profileId'],
                      request['name'], // اسم المستخدم
                      request['phoneNumber'], // رقم الهاتف
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('accept'.tr),
                ),
                ElevatedButton(
                  onPressed: () {
                    _rejectRequest(context, request['userId']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('reject'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(BuildContext context, String userId, String profileId,
      String userName, String userPhoneNumber) {
    // استخدم اسم المستخدم ورقم الهاتف هنا في أي سياق يناسبك، مثل عرضهم في مربع الحوار عند قبول الطلب
  }

  void _rejectRequest(BuildContext context, String userId) {
    // هنا يمكنك أيضًا استخدام اسم المستخدم ورقم الهاتف إذا كنت بحاجة إليها في سياق رفض الطلب
  }
}

void _acceptRequest(BuildContext context, String userId, String profileId) {
  FirebaseFirestore.instance
      .collection('coach_bookings')
      .doc(userId)
      .get()
      .then((doc) {
    if (doc.exists) {
      FirebaseFirestore.instance
          .collection('profile')
          .doc(profileId)
          .get()
          .then((profileDoc) {
        var name = profileDoc['name'];
        var phoneNumber = profileDoc['phoneNumber'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Booking_Details'.tr),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: $name'),
                  Text('Phone Number: $phoneNumber'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('coach_bookings')
                        .doc(userId)
                        .delete();
                    Navigator.of(context).pop();
                  },
                  child: Text('accept'.tr),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('cancel'.tr),
                ),
              ],
            );
          },
        );
      });
    }
  });
}

void _rejectRequest(BuildContext context, String userId) {
  FirebaseFirestore.instance
      .collection('coach_bookings')
      .doc(userId)
      .delete()
      .then((value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Rejected'),
          content: Text('The_booking_request_has_been_rejected.'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('oK'.tr),
            ),
          ],
        );
      },
    );
  });
}