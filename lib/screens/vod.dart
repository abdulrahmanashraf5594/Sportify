import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gallery_saver/gallery_saver.dart'; // إضافة الحزمة

typedef FirebaseTimestamp = Timestamp;

class VodafonePlayground extends StatelessWidget {
  final Map<String, dynamic>? bookingData;

  VodafonePlayground({Key? key, this.bookingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VodafonePlaygroundPage(bookingData: bookingData),
    );
  }
}

class VodafonePlaygroundPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const VodafonePlaygroundPage({Key? key, required this.bookingData}) : super(key: key);

  @override
  _VodafonePlaygroundPageState createState() => _VodafonePlaygroundPageState();
}

class _VodafonePlaygroundPageState extends State<VodafonePlaygroundPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  File? _image;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? _qrCodeImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay(hour: 10, minute: 0);
    _selectedEndTime = TimeOfDay(hour: 11, minute: 0); // Fixed end time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        backgroundColor: Color.fromARGB(255, 41, 169, 92),

        title: const Text('Vodafone Playground'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(
                        'Select Date:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedDate?.toLocal()}'.split(' ')[0] ?? 'Select Date',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.access_time),
                      SizedBox(width: 10),
                      Text(
                        'Select Time:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedStartTime?.format(context)} - ${_selectedEndTime?.format(context)}' ?? 'Select Time',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Text(
                        'Name:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 10),
                      Text(
                        'Phone Number:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _uploadImageAndSaveData,
                    icon: Icon(Icons.upload),
                    label: Text('Upload Image & Save Data'),
                  ),
                ),
                SizedBox(height: 20),
                _qrCodeImage != null
                    ? GestureDetector(
                  onTap: _saveQRImageToDevice,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Image.memory(base64Decode(_qrCodeImage!), height: 200, width: 200),
                          SizedBox(height: 10),
                          Text(
                            'Tap to save QR code',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );

    if (pickedStartTime != null && pickedStartTime != _selectedStartTime) {
      setState(() {
        _selectedStartTime = pickedStartTime;
        _selectedEndTime = TimeOfDay(hour: pickedStartTime.hour + 1, minute: pickedStartTime.minute);
      });
    }
  }

  Future<void> _uploadImageAndSaveData() async {
    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      if (_selectedDate != null && _selectedStartTime != null && _selectedEndTime != null) {
        final selectedDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedStartTime!.hour,
          _selectedStartTime!.minute,
        );
        final endTimeDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedEndTime!.hour,
          _selectedEndTime!.minute,
        );

        if (selectedDateTime.hour < 10 || endTimeDateTime.hour > 23) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected time must be within working hours (10 AM to 11 PM).'),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final startTime = FirebaseTimestamp.fromDate(selectedDateTime);
        final endTime = FirebaseTimestamp.fromDate(endTimeDateTime);
        final name = _nameController.text;
        final phoneNumber = _phoneController.text;

        final bookingData = {
          'date': _selectedDate,
          'start_time': startTime,
          'end_time': endTime,
          'name': name,
          'phone_number': phoneNumber,
        };

        final isTimeSlotBooked = await _firestoreService.checkTimeSlotAvailability(bookingData);
        if (!isTimeSlotBooked) {
          await _firestoreService.saveBookingDataWithImage(bookingData, _image!);

          // Generate and display QR code
          await _generateAndDisplayQRCode(bookingData.toString());

          // Send booking details to user email
          final email = _authService.currentUser?.email;
          if (email != null) {
            await _authService.sendBookingDetailsToUser(
              email,
              'Booking Date: ${_selectedDate?.toLocal()}\n'
                  'Time: ${_selectedStartTime?.format(context)} - ${_selectedEndTime?.format(context)}\n'
                  'Name: ${_nameController.text}\n'
                  'Phone: ${_phoneController.text}',
              _qrCodeImage!,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This time slot is already booked. Please select another time.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select date and time.'),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _generateAndDisplayQRCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;

      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: false,
        embeddedImageStyle: null,
        embeddedImage: null,
      );

      final picData = await painter.toImageData(280, format: ImageByteFormat.png);
      final bs64 = base64Encode(picData!.buffer.asUint8List());

      setState(() {
        _qrCodeImage = bs64;
      });
    } else {
      print('Error generating QR code: ${qrValidationResult.error}');
    }
  }

  Future<void> _saveQRImageToDevice() async {
    if (_qrCodeImage != null) {
      try {
        final Uint8List image = base64Decode(_qrCodeImage!);
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/qr_code.png';
        final File qrFile = File(imagePath);

        await qrFile.writeAsBytes(image);
        await GallerySaver.saveImage(imagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code image saved to gallery.'),
          ),
        );
      } catch (error) {
        print('Error saving QR code image: $error');
      }
    } else {
      print('QR code image is null.');
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkTimeSlotAvailability(Map<String, dynamic> bookingData) async {
    try {
      final startTime = bookingData['start_time'];
      final endTime = bookingData['end_time'];
      final DateTime date = bookingData['date'] as DateTime;

      final QuerySnapshot querySnapshot = await _firestore
          .collection('bookings')
          .where('date', isEqualTo: date)
          .where('start_time', isLessThan: endTime)
          .where('end_time', isGreaterThan: startTime)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking time slot availability: $error');
      return true;
    }
  }

  Future<void> saveBookingDataWithImage(Map<String, dynamic> bookingData, File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(image);
      final TaskSnapshot downloadUrl = await uploadTask;
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      bookingData['image_url'] = imageUrl;

      await _firestore.collection('bookings').add(bookingData);

      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently logged in user
  User? get currentUser => _auth.currentUser;

  // Send booking details and QR code to the user's email
  Future<void> sendBookingDetailsToUser(String email, String bookingDetails, String qrCodeImage) async {
    try {
      // Use a package like `mailer` or any other email sending service.
      // This is a placeholder for the actual email sending code.
      // For example, using `mailer` package:
      //
      // final smtpServer = gmail(username, password);
      // final message = Message()
      //   ..from = Address(username, 'Your name')
      //   ..recipients.add(email)
      //   ..subject = 'Booking Confirmation'
      //   ..html = '<h1>Booking Details:</h1>'
      //       '<p>$bookingDetails</p>'
      //       '<img src="data:image/png;base64,$qrCodeImage"/>';

      print('Email sent to $email with booking details and QR code.');
    } catch (error) {
      print('Error sending email: $error');
    }
  }
}

void main() {
  runApp(VodafonePlayground());
}