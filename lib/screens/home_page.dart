import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:untitled17/playground.dart';
import 'package:untitled17/profhome.dart';
import 'package:untitled17/screens/playdet.dart';
import 'package:untitled17/screens/side_menu.dart';
import '../events.dart';
import '../modareb.dart';
import '../notif.dart';
import '../pro.dart';
import 'history.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double xoffset = 0;
  double yoffset = 0;
  bool isDrawerOpen = false;

  var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double displayWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(
              bottom: displayWidth * .05,
              right: displayWidth * .05,
              left: displayWidth * .05),
          height: displayWidth * .155,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.5),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(50),
          ),
          child: StatefulBuilder(
            builder: (context, setStateHome) {
              return ListView.builder(
                itemCount: 4,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    setState(
                      () {
                        currentIndex = index;
                        // Navigate to the corresponding page based on the index
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryPage()),
                          );
                        } else if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationsPage()),
                          );
                        } else if (index == 3) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()));
                        }
                      },
                    );
                    index:
                    0;
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
                          height:
                              index == currentIndex ? displayWidth * .12 : 0,
                          width: index == currentIndex ? displayWidth * .32 : 0,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? Color.fromARGB(255, 134, 140, 143)
                                    .withOpacity(.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
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
                                      color: Colors.black87,
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
                                          color: Colors.black87,
                                        ),
                                      )
                                    : Icon(
                                        listOfIcons[index],
                                        size: displayWidth * .076,
                                        color: Colors.black26,
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
            },
          ),
        ),
        drawer: SideMenu(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Transform.rotate(
                    origin: Offset(20, -60),
                    angle: 2.4,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 60,
                        top: 40,
                      ),
                      height: screenSize.height * 0.6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(88),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          colors: [
                            Color.fromARGB(255, 207, 207, 213),
                            Color.fromARGB(255, 134, 140, 143),
                            Color.fromARGB(255, 207, 207, 213),
                          ],
                        ),
                      ),
                    ),
                  ),
                  LiquidPullToRefresh(
                    onRefresh: () async {
                      // قم بإعادة تحميل البيانات من Firebase هنا
                      // يمكنك استدعاء الدوال اللازمة لإعادة تحميل البيانات
                    },
                    child: SafeArea(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            // physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                AppBar(
                                  backgroundColor:
                                      Color.fromARGB(255, 134, 140, 143),
                                  iconTheme: IconThemeData.fallback(),
                                  title: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          child: CircleAvatar(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'images/spooooortttt.png'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Slider(),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Center(
                                        child: Text(
                                          "What are you looking for?",
                                          style: TextStyle(
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return EventScreen();
                                                  },
                                                ),
                                              );
                                            },
                                            child: NewPadding(
                                              image:
                                                  'images/Fitness_couple_running_vector_image_on_VectorStock-removebg-preview.png',
                                              text: 'Events',
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return Playground();
                                                  },
                                                ),
                                              );
                                            },
                                            child: NewPadding(
                                              image:
                                                  'images/Playgroundhome.png',
                                              text: 'Playground',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DisplayTrainersPage();
                                                  },
                                                ),
                                              );
                                            },
                                            child: NewPadding(
                                              image:
                                                  'images/WhatsApp_Image_2023-12-13_at_10.33.02_PM-removebg-preview.png',
                                              text: 'Trainers',
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DisplayProductsPage();
                                                  },
                                                ),
                                              );
                                            },
                                            child: NewPadding(
                                              image:
                                                  'images/ea819bf4-ebaf-49d0-9acd-60d8f0ee9aad-removebg-preview.png',
                                              text: 'Swap',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class NewPadding extends StatelessWidget {
  final String image;
  final String text;

  const NewPadding({
    Key? key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              width: 100,
              height: 25,
              color: Color(0xffF5F5F5),
              margin: EdgeInsets.only(top: 125, left: 30, bottom: 25),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Slider extends StatelessWidget {
  const Slider({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageAssets = [
      "images/events_home.jpeg",
      "images/off0.jpeg",
      "images/off.jpeg",
      "images/events.jpeg",
    ];
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 206.0,
          viewportFraction: 1,
          autoPlay: true,
          autoPlayCurve: Curves.easeInOutCubicEmphasized,
          autoPlayAnimationDuration: Duration(seconds: 1),
        ),
        items: imageAssets.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage(i),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: 110,
                          left: 24,
                          top: 35,
                        ),
                        width: 209,
                        height: 72,
                        child: Text(
                          "\n 50% Off",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
