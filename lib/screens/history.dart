import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/profhome.dart';
import 'package:untitled17/screens/home_page.dart';
import 'package:untitled17/screens/side_menu.dart';

import '../notif.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
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
        title: Text('History'.tr, style: TextStyle(color: Colors.white)),
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
                    // Add your widgets here
                    SizedBox(height: 20),
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
                    } else if (index == 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsPage()));
                    } else if (index == 3) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    }
                  });
                  index:
                  1;
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
                          ? displayWidth * .32
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
                                    ? displayWidth * .13
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
    'Home',
    'History',
    'Notification',
    'Profile',
  ];

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_active,
    Icons.person_rounded,
  ];
}
