// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:untitled17/profhome.dart';
// import 'package:untitled17/screens/home_page.dart';
// import 'package:untitled17/screens/side_menu.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:untitled17/main.dart';
// import 'history.dart';

// class NotificationsPage extends StatefulWidget {
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   var currentIndex = 2;
//   String? notificationMessage; // Add notification message variable

//   @override
//   void initState() {
//     super.initState();
//     // Set notification message when initializing the screen
//     notificationMessage = 'Your notification message here';
//     // Load notification message from Firestore
//     _loadNotificationMessage();
//   }

//   // Function to load notification message from Firestore
//   void _loadNotificationMessage() async {
//     try {
//       // Retrieve data from Firestore
//       var notificationDoc = await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc('notification_message')
//           .get();
//       if (notificationDoc.exists) {
//         setState(() {
//           notificationMessage = notificationDoc.data()?['message'];
//         });
//       } else {
//         setState(() {
//           notificationMessage = 'No notifications found';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         notificationMessage = 'Error loading notification';
//       });
//       print('Error loading notification: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double displayWidth = MediaQuery.of(context).size.width;
//     var themeProvider = Provider.of<ThemeProvider>(context);

//     Color appBarColor = themeProvider.themeMode == ThemeMode.dark
//         ? Colors.black
//         : Color.fromARGB(255, 221, 225, 231);
//     Color backgroundColor = themeProvider.themeMode == ThemeMode.dark
//         ? Colors.grey[900]!
//         : Color(0xffF5F5F5);
//     Color textColor =
//         themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;
//     Color backButtonColor =
//         themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: themeProvider.themeMode == ThemeMode.dark
//             ? Colors.grey[800]
//             : Colors.grey,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: Text('Notifications', style: TextStyle(color: Colors.white)),
//         iconTheme: IconThemeData(color: backButtonColor),
//       ),
//       backgroundColor: themeProvider.themeMode == ThemeMode.dark
//           ? Colors.grey[900]
//           : Colors.grey[200],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 // Add your widgets here
//                 SizedBox(height: 20),
//                 // Display the message loaded from Firestore
//                 Text(notificationMessage ?? 'Loading...'),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         margin: EdgeInsets.all(displayWidth * .05),
//         height: displayWidth * .155,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(.1),
//                 blurRadius: 30,
//                 offset: Offset(0, 10),
//               ),
//             ],
//             borderRadius: BorderRadius.circular(50)),
//         child: StatefulBuilder(
//           builder: (context, setStateHistory) {
//             return ListView.builder(
//               itemCount: 4,
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
//               itemBuilder: (context, index) => InkWell(
//                 onTap: () {
//                   setState(() {
//                     currentIndex = index;
//                     // Navigate to the corresponding page based on the index
//                     if (index == 0) {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => HomePage()));
//                     } else if (index == 1) {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => HistoryPage()));
//                     } else if (index == 3) {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ProfilePage()));
//                     }
//                   });
//                   index:
//                   2;
//                 },
//                 splashColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
//                 child: Stack(
//                   children: [
//                     AnimatedContainer(
//                       duration: Duration(seconds: 1),
//                       curve: Curves.fastLinearToSlowEaseIn,
//                       width: index == currentIndex
//                           ? displayWidth * .32
//                           : displayWidth * .18,
//                       alignment: Alignment.center,
//                       child: AnimatedContainer(
//                         duration: Duration(seconds: 1),
//                         curve: Curves.fastLinearToSlowEaseIn,
//                         height: index == currentIndex ? displayWidth * .12 : 0,
//                         width: index == currentIndex ? displayWidth * .32 : 0,
//                         decoration: BoxDecoration(
//                             color: index == currentIndex
//                                 ? Color.fromARGB(255, 134, 140, 143)
//                                     .withOpacity(.2)
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(50)),
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: Duration(seconds: 1),
//                       curve: Curves.fastLinearToSlowEaseIn,
//                       width: index == currentIndex
//                           ? displayWidth * .35
//                           : displayWidth * .18,
//                       alignment: Alignment.center,
//                       child: Stack(
//                         children: [
//                           Row(
//                             children: [
//                               AnimatedContainer(
//                                 duration: Duration(seconds: 1),
//                                 curve: Curves.fastLinearToSlowEaseIn,
//                                 width: index == currentIndex
//                                     ? displayWidth * .11
//                                     : 0,
//                               ),
//                               AnimatedOpacity(
//                                 opacity: index == currentIndex ? 1 : 0,
//                                 duration: Duration(seconds: 1),
//                                 curve: Curves.fastLinearToSlowEaseIn,
//                                 child: Text(
//                                   index == currentIndex
//                                       ? '${listOfString[index]}'
//                                       : '',
//                                   style: TextStyle(
//                                     color: Colors.black87,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               AnimatedContainer(
//                                 duration: Duration(seconds: 1),
//                                 curve: Curves.fastLinearToSlowEaseIn,
//                                 width: index == currentIndex
//                                     ? displayWidth * .03
//                                     : 20,
//                               ),
//                               index == 1
//                                   ? ScaleTransition(
//                                       scale: CurvedAnimation(
//                                           parent: AlwaysStoppedAnimation(1),
//                                           curve: Curves.fastLinearToSlowEaseIn),
//                                       child: Icon(
//                                         listOfIcons[index],
//                                         size: displayWidth * .076,
//                                         color: index == currentIndex
//                                             ? Colors.black87
//                                             : Colors.black26,
//                                       ),
//                                     )
//                                   : Icon(
//                                       listOfIcons[index],
//                                       size: displayWidth * .076,
//                                       color: index == currentIndex
//                                           ? Colors.black87
//                                           : Colors.black26,
//                                     ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<String> listOfString = [
//     'Home',
//     'History',
//     'Notification',
//     'Profile',
//   ];

//   List<IconData> listOfIcons = [
//     Icons.home_rounded,
//     Icons.history_rounded,
//     Icons.notifications_active,
//     Icons.person_rounded,
//   ];
// }
