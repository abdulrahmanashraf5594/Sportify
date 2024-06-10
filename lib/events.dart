import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/notif.dart';
import 'package:untitled17/screens/history.dart';
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
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
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
      child: Card(
        margin: EdgeInsets.all(10),
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
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'event_type'.tr + ' ${widget.data['eventType']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'distance'.tr + ' ${widget.data['distance']}',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'fee'.tr + ' ${widget.data['fee']}',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'insurance'.tr + ' ${widget.data['insurance']}',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: isSubscribed
                            ? null
                            : () => _subscribeToEvent(context, widget.data),
                        child: Text(
                          isSubscribed ? 'subscribed'.tr : 'subscribe'.tr,
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
                        'subscribers'.tr + ' $subscribersCount',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
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
        String gender = 'male'.tr; // Initial value for gender
        String phone = '';

        List<String> genderOptions = ['male'.tr, 'female'.tr];

        return AlertDialog(
          title: Text('subscribe_to_event'.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField(context, 'name'.tr, (value) => name = value),
                _buildTextField(context, 'age'.tr, (value) => age = value),
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
                _buildTextField(
                    context, 'phone_number'.tr, (value) => phone = value),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'cancel'.tr,
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
                    'name'.tr: name,
                    'age'.tr: age,
                    'gender'.tr: gender, // Use the selected gender value here
                    'phone'.tr: phone,
                    'userId'.tr: userId,
                  };

                  // Use event ID and user ID as a unique identifier for the subscription
                  final CollectionReference eventSubscribersCollection =
                  FirebaseFirestore.instance.collection(
                      'event_subscribers_${eventData['eventId']}');
                  eventSubscribersCollection.add(subscriberData).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('successfully')),
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
                'subscribe'.tr,
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

  Widget _buildTextField(
      BuildContext context, String label, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label.tr),
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
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('event_details'.tr),
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
                  _buildInfoCard(context,
                      title: 'event_name'.tr, value: '${event['eventName']}'),
                  _buildInfoCard(context,
                      title: 'status'.tr, value: '${event['status']}'),
                  _buildInfoCard(context,
                      title: 'age_range'.tr,
                      value: '${event['ageRangeFrom']}-${event['ageRangeTo']}'),
                  _buildInfoCard(context,
                      title: 'description'.tr,
                      value: '${event['description']}'),
                  if (event['distance'] != null)
                    _buildInfoCard(context,
                        title: 'distance'.tr, value: '${event['distance']}'),
                  if (event['date'] != null)
                    _buildInfoCard(context,
                        title: 'date'.tr, value: '${event['date']}'),
                  _buildInfoCard(context,
                      title: 'event_type'.tr, value: '${event['eventType']}'),
                  _buildInfoCard(context,
                      title: 'fee'.tr, value: '${event['fee']}'),
                  if (event['haveBike'] != null)
                    _buildInfoCard(context,
                        title: 'have_bike'.tr, value: '${event['haveBike']}'),
                  _buildInfoCard(context,
                      title: 'insurance'.tr, value: '${event['insurance']}'),
                  SizedBox(height: 10),
                  // Add button to open Google Maps
                  ElevatedButton(
                    onPressed: () {
                      // Pass the event address to the function
                      _launchMaps('${event['address']}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 41, 169, 92),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,color: Colors.white,),
                          SizedBox(width: 10),
                          Text('show location in maps'.tr,style: TextStyle(color: Colors.white),),
                        ],
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

  Widget _buildInfoCard(BuildContext context, {required String title, required String value}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;

  const DetailScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(imageUrl),
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
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('events'.tr),
      ),
      body: LiquidPullToRefresh(
        onRefresh: () async {
          // عملية التحميل هنا
        },
        child: SafeArea(
          child: Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('accepted_events')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                        'images/animation/loading.json',
                        height: 250,
                        width: 250,
                        repeat: true,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final events = snapshot.data!.docs;
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
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
                  );
                },
              ),
              Positioned(
                child: CircularMenu(
                  alignment: Alignment.bottomRight,
                  toggleButtonColor: Color.fromARGB(255, 41, 169, 92),
                  items: [
                    CircularMenuItem(
                      icon: Icons.add_outlined,
                      color: Colors.blue,
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
                              builder: (context) => NotificationsPage()),
                        );
                      },
                    ),
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
                  hintText: 'search'.tr,
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
