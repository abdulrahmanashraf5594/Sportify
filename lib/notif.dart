import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled17/profhome.dart';
import 'package:untitled17/screens/history.dart';
import 'package:untitled17/screens/home_page.dart';
import 'package:untitled17/screens/side_menu.dart';
import 'package:untitled17/screens/userevent.dart';

import 'events.dart';
import 'main.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  var currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
    Color backButtonColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('notifications'.tr),
        iconTheme: IconThemeData(color: backButtonColor),
      ),
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Colors.grey[900]
          : Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('accepted_events')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('لا توجد فعاليات حالياً'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var event = snapshot.data!.docs[index];
                            var eventName = event['name'];
                            var eventType = event['eventType'];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New events have been added with a name: $eventName'
                                          .tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'event type: $eventType'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Visit_the_events_page_now_to_see_what_is_new'
                                          .tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
            bottom: displayWidth * .05,
            right: displayWidth * .05,
            left: displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Color.fromARGB(255, 41, 41, 41)
                : Colors.white,
            borderRadius: BorderRadius.circular(50)),
        child: StatefulBuilder(
          builder: (context, setStateHistory) {
            return ListView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                    // Navigate to the corresponding page based on the index
                    if (index == 0) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    } else if (index == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscribersPage()));
                    } else if (index == 3) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    }
                  });
                  index:
                  2;
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentIndex
                          ? displayWidth * .32
                          : displayWidth * .18,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        height: index == currentIndex ? displayWidth * .12 : 0,
                        width: index == currentIndex ? displayWidth * .32 : 0,
                        decoration: BoxDecoration(
                            color: index == currentIndex
                                ? Color.fromARGB(255, 134, 140, 143)
                                    .withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentIndex
                          ? displayWidth * .35
                          : displayWidth * .18,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayWidth * .11
                                    : 0,
                              ),
                              AnimatedOpacity(
                                opacity: index == currentIndex ? 1 : 0,
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                child: Text(
                                  index == currentIndex
                                      ? '${listOfString[index]}'
                                      : '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(seconds: 1),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentIndex
                                    ? displayWidth * .03
                                    : 20,
                              ),
                              index == currentIndex
                                  ? ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: AlwaysStoppedAnimation(1),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                      ),
                                      child: Icon(
                                        listOfIcons[index],
                                        size: displayWidth * .076,
                                        color: textColor,
                                      ),
                                    )
                                  : Icon(
                                      listOfIcons[index],
                                      size: displayWidth * .076,
                                      color: Colors.black26,
                                    ),
                            ],
                          )
                        ],
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

  List<String> listOfString = [
    'home'.tr,
    'history'.tr,
    'notification'.tr,
    'profile'.tr,
  ];

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_active,
    Icons.person_rounded,
  ];
}
