import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  File? _image;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? _qrCodeImage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay(hour: 10, minute: 0);
    _selectedEndTime = TimeOfDay(hour: 1, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vodafone Playground'),
      ),
      body: SingleChildScrollView(
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
                ? Center(child: Image.memory(base64Decode(_qrCodeImage!)))
                : SizedBox(),
          ],
        ),
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
              content: Text('Selected time must be within working hours (10 AM to 1 AM).'),
            ),
          );
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This time slot is already booked. Please select another time.'),
            ),
          );
        }
      } else {
        print('Please select date and time');
      }
    }
  }

  Future<void> _generateAndDisplayQRCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H, // زيادة مستوى تصحيح الخطأ
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

      // تغيير حجم الصورة إلى 100 بكسل
      final picData = await painter.toImageData(280, format: ImageByteFormat.png); // تغيير الحجم إلى 100 بكسل
      final bs64 = base64Encode(picData!.buffer.asUint8List());

      setState(() {
        _qrCodeImage = bs64;
      });

      final directory = (await getApplicationDocumentsDirectory()).path;
      final imagePath = await File('$directory/qr_code.png').create();
      await imagePath.writeAsBytes(picData.buffer.asUint8List());
    } else {
      print('Error generating QR code: ${qrValidationResult.error}');
    }
  }

}


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkTimeSlotAvailability(Map<String, dynamic> bookingData) async {
    try {
      final startTime = bookingData['start_time'];
      final endTime = bookingData['end_time'];
      final DateTime date = bookingData['date'];

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
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      bookingData['image_url'] = imageUrl;

      await _firestore.collection('bookings').add(bookingData);

      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }
}

void main() {
  runApp(VodafonePlayground());
}
