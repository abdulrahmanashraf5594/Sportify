import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<String> descriptions = [
    'Experience a unique and comprehensive sports journey with our app, which allows you to organize your sports events, book sports fields, exchange sports equipment, and communicate directly with personal trainers online, all with ease',
    'Book training sessions with coaches effortlessly and communicate directly with them to arrange session details and seek sports advice',
    'Enjoy a unique sports experience with Sportify, the app that makes booking and participating in sports events smoother than ever.',
    'Experience a unique sports swapping journey you! Utilize the exchange section in the app to upgrade your sports gear effortlessly.',
    'We are proud to present our application developed by a distinguished team of graduates from Al-Shorouk Academy, Team 13, who graduated in 2024. Get to know this creative team and explore their innovations through our amazing app!',
  ];

  List<String> lottieFiles = [
    'images/animation/aboutapp.json',
    'images/animation/AWdemdKN7a.json',
    'images/animation/aboutevent.json',
    'images/animation/GceB90JaDF.json',
    'images/animation/team13.json',
  ];

  int _currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // تأخير تغيير isLoading لبعض الوقت لعرض مؤشر التحميل
    Future.delayed(Duration(milliseconds: 3100), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> carouselItems =
    descriptions.asMap().entries.map((MapEntry<int, String> entry) {
      int index = entry.key;
      return Builder(
        builder: (BuildContext context) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 200),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6),
                              Text(
                                descriptions[_currentIndex],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.clip,
                                maxLines: 10,
                                strutStyle: StrutStyle(
                                  height: 1.5,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Positioned(
                      top: -MediaQuery.of(context)
                          .padding
                          .top, // تحديد الموقع الرأسي للصورة مع استخدام حجم padding العلوي
                      left: 0, // تحديد الموقع الأفقي للصورة
                      child: SizedBox(
                        height: 220,
                        width: 300,
                        child: Lottie.asset(
                          lottieFiles[_currentIndex],
                          repeat: true, // تكرار التحريك
                          animate: true, // تشغيل التحريك تلقائيا
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'images/animation/loading.json',
                          height: 250,
                          width: 250,
                          repeat: true,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Just a moment,\nwe\'re preparing the best\npresentation capabilities for you...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: CarouselSlider(
                      key: ValueKey<int>(_currentIndex),
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.7,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: carouselItems,
                    ),
                  ),
          ),
          if (!isLoading) // هنا يتم عرض عناصر الأزرار بعد انتهاء التحميل
            Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentIndex > 0) {
                          setState(() {
                            _currentIndex--;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex > 0
                              ? Color.fromARGB(255, 41, 169, 92)
                              : Colors.grey.withOpacity(0.5),
                        ),
                        child: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: descriptions
                          .asMap()
                          .entries
                          .map((MapEntry<int, String> entry) {
                        int index = entry.key;
                        return Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Color.fromARGB(255, 41, 169, 92)
                                : Colors.grey.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        if (_currentIndex < descriptions.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex < descriptions.length - 1
                              ? Color.fromARGB(255, 41, 169, 92)
                              : Colors.grey.withOpacity(0.5),
                        ),
                        child:
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}
