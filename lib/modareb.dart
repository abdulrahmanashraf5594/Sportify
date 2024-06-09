import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/payments.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayTrainersPage extends StatefulWidget {
  @override
  _DisplayTrainersPageState createState() => _DisplayTrainersPageState();
}

class _DisplayTrainersPageState extends State<DisplayTrainersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  // دالة لفتح الروابط
  _launchURL(String? url) async {
    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    
    
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Display_Trainers'.tr),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(30),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "search".tr,
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
            ),
            SizedBox(
              height: 18,
            ),
            Category(themeProvider: themeProvider), // تمرير themeProvider هنا
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SizedBox(
              height: 18,
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('approved_trainers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var trainers = snapshot.data!.docs;

                // Filter trainers based on the search input
                var filteredTrainers = trainers.where((trainer) {
                  var trainerName = trainer['name'].toString().toLowerCase();
                  var searchQuery = _searchController.text.toLowerCase();
                  return trainerName.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredTrainers.length,
                  itemBuilder: (context, index) {
                    var trainer =
                        filteredTrainers[index].data()! as Map<String, dynamic>;
                    return TrainerCard(
                      trainer: trainer,
                      // تمرير دالة فتح الروابط كوسيطة
                      launchURL: _launchURL,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TrainerCard extends StatelessWidget {
  final Map<String, dynamic> trainer;
  final Function(String?) launchURL;

  TrainerCard({required this.trainer, required this.launchURL});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainerDetailsScreen(trainer: trainer),
          ),
        );
      },
      child: Card(
        color: cardColor,
        elevation: 5,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trainer['profileImage'] != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      trainer['profileImage'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Text(
                'name: ${trainer['name']}'.tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              Text(
                'experience: ${trainer['experience']} years'.tr,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              Text(
                'age: ${trainer['age']}'.tr,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              Text(
                'sport: ${trainer['sport']}'.tr,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  if (trainer['linkedin'] != null) ...[
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        launchURL(trainer['linkedin']);
                      },
                      child: Image.asset(
                        'images/in-removebg-preview.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Spacer(),
                  ],
                  if (trainer['youtube'] != null) ...[
                    GestureDetector(
                      onTap: () {
                        launchURL(trainer['youtube']);
                      },
                      child: Image.asset(
                        'images/Youtube-removebg-preview.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Spacer(),
                  ],
                  if (trainer['instagram'] != null) ...[
                    GestureDetector(
                      onTap: () {
                        launchURL(trainer['instagram']);
                      },
                      child: Image.asset(
                        'images/instagram.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Spacer(),
                  ],
                  if (trainer['twitter'] != null) ...[
                    GestureDetector(
                      onTap: () {
                        launchURL(trainer['twitter']);
                      },
                      child: Image.asset(
                        'images/X-removebg-preview.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Spacer(),
                  ],
                  if (trainer['facebook'] != null) ...[
                    GestureDetector(
                      onTap: () {
                        launchURL(trainer['facebook']);
                      },
                      child: Image.asset(
                        'images/facebook.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Spacer(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  final ThemeProvider themeProvider;

  const Category({Key? key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;

    return Column(
      children: [
        Container(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        categoryIcon(
                            'paddel'.tr, "images/paddel.jpeg", textColor),
                        const SizedBox(width: 12),
                        categoryIcon(
                            'football'.tr, "images/football.jpeg", textColor),
                        const SizedBox(width: 12),
                        categoryIcon('basketball'.tr, "images/basketball.jpeg",
                            textColor),
                        const SizedBox(width: 12),
                        categoryIcon('volleyball'.tr, "images/volleyball.jpeg",
                            textColor),
                        const SizedBox(width: 12),
                        categoryIcon(
                            'tennis'.tr, "images/tennis.jpeg", textColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }

  Widget categoryIcon(String text, String image, Color textColor) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            child: CircleAvatar(
              backgroundImage: AssetImage(image),
              radius: 34,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            child: Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trainer;

  TrainerDetailsScreen({required this.trainer});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('Trainer_Details'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trainer['profileImage'] != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    trainer['profileImage'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            _buildInfoItem(
                context, 'name:'.tr, '${trainer['name']}'.tr, textColor),
            SizedBox(height: 8),
            _buildInfoItem(context, 'experience:'.tr,
                '${trainer['experience']} years', textColor),
            SizedBox(height: 8),
            _buildInfoItem(
                context, 'age:'.tr, '${trainer['age']}'.tr, textColor),
            SizedBox(height: 8),
            _buildInfoItem(
                context, 'sport:'.tr, '${trainer['sport']}'.tr, textColor),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Buy();
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 41, 169, 92),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'subscribe'.tr,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String title, String value, Color textColor) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
