import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference coachBookings = FirebaseFirestore.instance.collection('CoachBookings');

  final CollectionReference approvedCoachBookings = FirebaseFirestore.instance.collection('ApprovedCoachBookings');

  Future<void> moveApprovedRequest() async {
    final QuerySnapshot bookingSnapshot = await coachBookings.get();

    if (bookingSnapshot.docs.isNotEmpty) {
      final QueryDocumentSnapshot bookingDoc = bookingSnapshot.docs.first;
      final requestData = bookingDoc.data();

      await approvedCoachBookings.add(requestData);
      await coachBookings.doc(bookingDoc.id).delete();
    }
  }

  Future<bool> checkTimeSlotAvailability(Map<String, dynamic> bookingData) async {
    try {
      final startTime = bookingData['start_time'];
      final endTime = bookingData['end_time'];
      final DateTime date = bookingData['date'];

      final QuerySnapshot querySnapshot = await _firestore
          .collection('coach_bookings')
          .where('date', isEqualTo: date)
          .where('start_time', isLessThan: endTime)
          .where('end_time', isGreaterThan: startTime)
          .get();

      // If there are any documents returned, it means the time slot is already booked
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking time slot availability: $error');
      return true; // Assuming there's an error, so treat it as the time slot is already booked
    }
  }

  Future<void> saveBookingDataWithImage(Map<String, dynamic> bookingData, File image) async {
    try {
      // Upload the image to Firebase Storage
      // For simplicity, I'm assuming you have already set up Firebase Storage and have a reference to the location where you want to save the image
      // Replace 'images' with your actual storage path
      final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(image);
      final TaskSnapshot downloadUrl = await uploadTask;
      final String imageUrl = await downloadUrl.ref.getDownloadURL();

      // Add the image URL to the booking data
      bookingData['image_url'] = imageUrl;

      // Save the booking data to Firestore
      await _firestore.collection('coach_bookings').add(bookingData);

      print('Booking data saved successfully!');
    } catch (error) {
      print('Error saving booking data: $error');
    }
  }
}

class Buy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
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
                padding:
                EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Text(
                    'Electronic wallet',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MySample();
                    },
                  ),
                );
              },
              child: Container(
                padding:
                EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Text(
                    'Visa',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.white),
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


class MySample extends StatefulWidget {
  const MySample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MySampleState();
}

class MySampleState extends State<MySample> {
  bool isLightTheme = false; // حالة الثيم الحالي (فاتح/داكن)
  String cardNumber = ''; // رقم البطاقة
  String expiryDate = ''; // تاريخ انتهاء الصلاحية
  String cardHolderName = ''; // اسم صاحب البطاقة
  String cvvCode = ''; // رمز CVV
  bool isCvvFocused = false; // هل تم التركيز على رمز CVV
  bool useGlassMorphism = false; // هل يجب استخدام تأثير "Glassmorphism"
  bool useBackgroundImage = false; // هل يجب استخدام صورة خلفية
  bool useFloatingAnimation = true; // هل يجب استخدام الرسوم المتحركة الطافية
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>(); // مفتاح عالمي لنموذج البطاقة

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Card View',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        // ثيم النصوص والحقول النصية في حالة الثيم الفاتح
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.black, fontSize: 18),
        ),
        // تكوين الألوان لحالة الثيم الفاتح
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.black,
          background: Colors.white,
          primary: Colors.black,
        ),
        // تصميم الحقول النصية
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        // ثيم النصوص والحقول النصية في حالة الثيم الداكن
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
        // تكوين الألوان لحالة الثيم الداكن
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.black,
          background: Colors.white,
          primary: Colors.white,
        ),
        // تصميم الحقول النصية
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Card View'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // عنصر عرض بطاقة الائتمان
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Axis Bank',
                      backgroundImage: 'images/visa.jpg',
                      frontCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      backCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      // تعيين صورة خلفية مخصصة إذا تم تفعيلها
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard,
                          cardImage: Image.asset(
                            'assets/mastercard.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            // نموذج إدخال بيانات بطاقة الائتمان
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                ),
                              ),
// دالة تنفيذ عند تغيير البيانات في نموذج البطاقة
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
// زر "Validate" للتحقق من صحة البيانات
                            GestureDetector(
                              onTap: _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFB58D67),
                                      Color(0xFFE5D1B2),
                                      Color(0xFFF9EED2),
                                      Color(0xFFEFEFED),
                                      Color(0xFFF9EED2),
                                      Color(0xFFB58D67),
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'halter',
                                    fontSize: 14,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

// دالة التحقق من صحة البيانات
  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('صحيحة!');
    } else {
      print('غير صحيحة!');
    }
  }

// دالة لإرجاع تكوين "Glassmorphism" المطلوب
  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

// دالة تنفيذ عند تغيير البيانات في نموذج بطاقة الائتمان
  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

class Vodafone extends StatefulWidget {
  @override
  _VodafoneState createState() => _VodafoneState();
}

class _VodafoneState extends State<Vodafone> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

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
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32.0),
              GestureDetector(
                onTap: () async {
                  // Add your conditions for navigation here
                  // For example, check if phoneNumberError and amountError are empty
                  // before navigating to the UploadScreen
                  await _firestoreService.moveApprovedRequest();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VodafonePlayground()),
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

class VodafonePlayground extends StatelessWidget {
  final Map<String, dynamic>? bookingData;

  VodafonePlayground({Key? key, this.bookingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  TimeOfDay? _selectedStartTime; // الوقت البدء
  TimeOfDay? _selectedEndTime; // الوقت الانتهاء
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = TimeOfDay(hour: _selectedStartTime!.hour + 1, minute: _selectedStartTime!.minute); // افتراض أن مدة الحجز ساعة واحدة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vodafone Playground'),
      ),
      body: Column(
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
          Center(
            child: ElevatedButton.icon(
              onPressed: _uploadImageAndSaveData,
              icon: Icon(Icons.upload),
              label: Text('Upload Image & Save Data'),
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
        _selectedEndTime = TimeOfDay(hour: pickedStartTime.hour + 1, minute: pickedStartTime.minute); // تحديث الوقت الانتهاء عند تغيير الوقت البدء
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
        final startTimeAsString = _selectedTimeToString(_selectedStartTime!);
        final endTimeAsString = _selectedTimeToString(_selectedEndTime!);
        final bookingData = {
          'date': _selectedDate,
          'start_time': startTimeAsString,
          'end_time': endTimeAsString,
          'name': _nameController.text, // اسم الحاجز
          'phone_number': _phoneNumberController.text, // رقم الهاتف للحاجز
          // يمكنك إضافة المزيد من معلومات الحجز هنا
        };

        // Check if the selected time slot is already booked
        final isTimeSlotBooked = await _firestoreService.checkTimeSlotAvailability(bookingData);
        if (!isTimeSlotBooked) {
          // Time slot is available, proceed to save the booking data
          await _firestoreService.saveBookingDataWithImage(bookingData, _image!);
        } else {
          // Time slot is already booked, show a message to the user
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

  String _selectedTimeToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

void main() {
  runApp(MaterialApp(
    home: Buy(),
  ));
}
