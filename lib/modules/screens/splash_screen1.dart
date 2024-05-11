import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation after 500 milliseconds (you can adjust this delay)
    Future.delayed(Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    // Navigate to the next screen after 3 seconds (you can adjust this delay)
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => splashscreen(),
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'images/spooooortttt.png',
                    height: 150,
                    width: 150,
                  ),

                ),

              ),
              SizedBox(
                height: 20,
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}



// ignore_for_file: prefer_const_constructors, unused_field, prefer_final_fields, annotate_overrides, curly_braces_in_flow_control_structures, unused_import

class splashscreen extends StatefulWidget {
  splashscreen({Key? key}) : super(key: key);

  @override
  State<splashscreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<splashscreen> {
  late PageController _pageController;

  int _pageIndex = 0;

  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 19, 19, 19),
        body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 34, 72, 104),
                  Color.fromARGB(255, 36, 106, 39)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
              child: Column(children: [
                Expanded(
                    child: SafeArea(
                        child: PageView.builder(
                            itemCount: demo_data.length,
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _pageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) => OnboardContent(
                              image: demo_data[index].image,
                              title: demo_data[index].title,
                              description: demo_data[index].description,
                            )))),
                Row(
                  children: [
                    ...List.generate(
                        demo_data.length,
                            (index) => Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: DotIndicators(
                            isActive: index == _pageIndex,
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(50.0),
                    ),
                    Spacer(),
                    SizedBox(
                        height: 60,
                        width: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_pageIndex == 3) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            } else
                              (_pageController.nextPage(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.ease,
                              ));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ]),
            )));
  }
}

class OnBoard {
  final String image, title, description;
  OnBoard(
      {required this.image, required this.title, required this.description});
}

final List demo_data = [
  OnBoard(
      image: 'images/playground.png',
      title: 'Through the application, you can book a playground',
      description: 'Just turn on your location!!'),
  OnBoard(
      image: 'images/trainer.png',
      title: 'Also ,you can sing up with personal trainers',
      description: 'Get the best trainers'),
  OnBoard(
      image: 'images/running.png',
      title: 'And you can join different of sporting events',
      description: 'Get the best events'),
  OnBoard(
    image: 'images/swap.png',
    title: 'At the end ,you can Swap your different sports equipment',
    description: 'What are you waiting for, log in now',
  )
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, height: 250),
        SizedBox(height: 30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style:
          GoogleFonts.openSans(fontSize: 14, color: Colors.grey.shade400),
        )
      ],
    );
  }
}

class DotIndicators extends StatelessWidget {
  const DotIndicators({
    Key? key,
    this.isActive = false,
  }) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.white),
    );
  }
}