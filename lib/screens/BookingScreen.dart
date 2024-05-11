import 'package:flutter/material.dart';

import '../payments.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InteractiveCalendarScreen(),
    );
  }
}

class InteractiveCalendarScreen extends StatefulWidget {
  @override
  _InteractiveCalendarScreenState createState() => _InteractiveCalendarScreenState();
}

class _InteractiveCalendarScreenState extends State<InteractiveCalendarScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(16),
            child: Text(
              'Select Date:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedDate?.toLocal()}'.split(' ')[0] ?? 'Select Date',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: Text(
              'Select Time:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedTime?.format(context)}' ?? 'Select Time',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // عند الضغط على زر "تأكيد الميعاد"
              // يمكنك هنا استخدام Navigator.push لفتح صفحة "BayScreen"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Buy()),
              );
            },
            child: Text('Confirm Time'),
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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _confirmTime() {
    if (_selectedDate != null && _selectedTime != null) {
      print('Confirmed Date: $_selectedDate');
      print('Confirmed Time: $_selectedTime');
    } else {
      print('Please select date and time');
    }
  }
}


