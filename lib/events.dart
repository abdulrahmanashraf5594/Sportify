import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled17/history.dart';
import 'package:untitled17/screens/userevent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'AddEventScreen.dart';

class EventCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const EventCard({Key? key, required this.data}) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  int subscribersCount = 0;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _getSubscribersCount();
    _checkIfSubscribed();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? images = (widget.data['images'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: widget.data),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images != null && images.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.network(
                        images[index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 12),
            Text(
              'Event Type: ${widget.data['eventType']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Distance: ${widget.data['distance']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Fee: ${widget.data['fee']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Insurance: ${widget.data['insurance']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isSubscribed
                      ? null
                      : () => _subscribeToEvent(context, widget.data),
                  child: Text(
                    isSubscribed ? 'Subscribed' : 'Subscribe',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 41, 169, 92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Subscribers: $subscribersCount',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getSubscribersCount() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('event_subscribers_${widget.data['eventId']}')
        .get();
    setState(() {
      subscribersCount = snapshot.docs.length;
    });
  }

  Future<void> _checkIfSubscribed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('event_subscribers_${widget.data['eventId']}')
        .where('userId', isEqualTo: userId)
        .get();
    setState(() {
      isSubscribed = snapshot.docs.isNotEmpty;
    });
  }

  void _subscribeToEvent(BuildContext context, Map<String, dynamic> eventData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String age = '';
        String gender = 'Male'; // Initial value for gender
        String phone = '';

        List<String> genderOptions = ['Male', 'Female'];

        return AlertDialog(
          title: Text('Subscribe to Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField('Name', (value) => name = value),
                _buildTextField('Age', (value) => age = value),
                DropdownButton(
                  hint: Text('Select Gender'),
                  value: gender,
                  onChanged: (newValue) {
                    gender = newValue.toString();
                  },
                  items: genderOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                _buildTextField('Phone', (value) => phone = value),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 41, 169, 92),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Check for empty fields and validity
                if (name.isEmpty || age.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Check age validity
                if (int.tryParse(age) == null || int.tryParse(age)! < 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Age must be a number and at least 16')),
                  );
                  return;
                }

                // Check phone validity
                if (!phone.startsWith('01') || phone.length != 11) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Phone number must start with 01 and be 11 digits')),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Handle the case where the user is not logged in
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please log in to subscribe to the event'),
                    ),
                  );
                  Navigator.of(context).pop(); // Close dialog
                  return;
                }

                final userId = user.uid;

                // Check if the user is already subscribed to this event
                final QuerySnapshot existingSubscription =
                    await FirebaseFirestore.instance
                        .collection('event_subscribers_${eventData['eventId']}')
                        .where('userId', isEqualTo: userId)
                        .get();

                if (existingSubscription.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('You are already subscribed to this event!'),
                    ),
                  );
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  // Save subscriber data to a new collection for event subscriptions
                  Map<String, dynamic> subscriberData = {
                    'name': name,
                    'age': age,
                    'gender': gender, // Use the selected gender value here
                    'phone': phone,
                    'userId': userId,
                  };

                  // Use event ID and user ID as a unique identifier for the subscription
                  final CollectionReference eventSubscribersCollection =
                      FirebaseFirestore.instance.collection(
                          'event_subscribers_${eventData['eventId']}');
                  eventSubscribersCollection.add(subscriberData).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Subscribed to the event successfully!')),
                    );
                    Navigator.of(context).pop(); // Close dialog

                    // Update subscribers count after subscribing
                    _getSubscribersCount();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to subscribe to the event: $error')),
                    );
                  });

                  // Refresh the EventScreen after subscription
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => EventScreen()),
                  );
                }
              },
              child: Text(
                'Subscribe',
                style: TextStyle(
                  color: Color.fromARGB(255, 41, 169, 92),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  EventDetailsScreen({required this.event});

  // Function to open Google Maps
  _launchMaps(String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$address';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (event['images'] != null &&
                      (event['images'] as List).isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (event['images'] as List).length,
                        itemBuilder: (context, index) {
                          String imageUrl = event['images'][index];
                          return Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return DetailScreen(imageUrl: imageUrl);
                                }));
                              },
                              child: Hero(
                                tag: imageUrl,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    imageUrl,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                      title: 'Event Name', value: '${event['eventName']}'),
                  _buildInfoCard(title: 'Status', value: '${event['status']}'),
                  _buildInfoCard(
                      title: 'Age Range',
                      value: '${event['ageRangeFrom']}-${event['ageRangeTo']}'),
                  _buildInfoCard(
                      title: 'Description', value: '${event['description']}'),
                  if (event['distance'] != null)
                    _buildInfoCard(
                        title: 'Distance', value: '${event['distance']}'),
                  if (event['date'] != null)
                    _buildInfoCard(title: 'Date', value: '${event['date']}'),
                  _buildInfoCard(
                      title: 'Event Type', value: '${event['eventType']}'),
                  _buildInfoCard(title: 'Fee', value: '${event['fee']}'),
                  if (event['haveBike'] != null)
                    _buildInfoCard(
                        title: 'Have Bike', value: '${event['haveBike']}'),
                  _buildInfoCard(
                      title: 'Insurance', value: '${event['insurance']}'),
                  SizedBox(height: 10),
                  // Add button to open Google Maps
                  ElevatedButton(
                    onPressed: () {
                      // Pass the event address to the function
                      _launchMaps('${event['address']}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 41, 169, 92), // Background color

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24), // Button padding
                    ),
                    child: Text(
                      'View Location on Google Maps',
                      style: TextStyle(
                          fontSize: 16, // Text size
                          fontWeight: FontWeight.bold,
                          color: Colors.white // Bold text
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build info card
  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;

  DetailScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}

class EventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
      ),
      body: LiquidPullToRefresh(
        // هنا نقوم بتحديث البيانات عند سحب الشاشة لأسفل
        onRefresh: () async {
          EventList();
          final Map<String, dynamic> data;

          // قم بإعادة تحميل البيانات من Firebase هنا
          // يمكنك استدعاء الدوال اللازمة لإعادة تحميل البيانات
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), // تمكين السحب لأسفل
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SearchBar(),
                      SizedBox(height: 20),
                      EventList(),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: CircularMenu(
                  alignment: Alignment.bottomRight,
                  toggleButtonColor: Colors.blue,
                  items: [
                    CircularMenuItem(
                      icon: Icons.add_outlined,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEventScreen()),
                        );
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.text_snippet_outlined,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscribersPage()),
                        );
                      },
                    ),
                    CircularMenuItem(
                      icon: Icons.history,
                      color: Colors.brown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryPage()),
                        );
                        // صفحة الايفينتات القديمه
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('accepted_events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final events = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return EventCard(data: event);
          },
        );
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with your SearchBar implementation
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          SizedBox(width: 12),
          ClipOval(
            child: Image.asset(
              "images/spooooortttt.png",
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
