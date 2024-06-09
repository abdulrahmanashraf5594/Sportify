import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/screens/playdet.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

class Playground extends StatefulWidget {
  const Playground({Key? key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

 
    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'playground'.tr,
          style: TextStyle(color: textColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                ),
                SizedBox(
                  height: 18,
                ),
                Category(),
                const Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 18,
                ),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: (selectedCity.isEmpty)
                      ? FirebaseFirestore.instance.collection('stadiums').get()
                      : FirebaseFirestore.instance
                          .collection('stadiums')
                          .where('city', isEqualTo: selectedCity)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No data available'));
                    } else {
                      List<DocumentSnapshot> playgrounds = snapshot.data!.docs;

                      return Column(
                        children: playgrounds.map((playground) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 18,
                              ),
                              PlaygroundCard(
                                  data: playground.data()
                                      as Map<String, dynamic>),
                            ],
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlaygroundCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PlaygroundCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = (data['imageUrl'] as List<dynamic>).cast<String>();
    final price = data['price'] as String? ?? '';
    final name = data['name'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaygroundDetailsPage(playgroundData: data),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return NewWidget(
                imge: imageUrls[index],
                data: data,
                name: name,
                price: price,
              );
            },
          ),
        ],
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  final String imge;
  final Map<String, dynamic> data;
  final String name;
  final String price;

  const NewWidget(
      {Key? key,
      required this.imge,
      required this.data,
      required this.name,
      required this.price})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight * 0.3;

    return Container(
      height: cardHeight,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Card(
          color: Colors.grey[300],
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imge),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  const Category({Key? key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
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

class DistrictList extends StatefulWidget {
  @override
  _DistrictListState createState() => _DistrictListState();
}

class _DistrictListState extends State<DistrictList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        backgroundColor: Color.fromARGB(255, 41, 169, 92),

        title: Text('Districts'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Al-Mokattam'),
            onTap: () {
              Navigator.pop(context, 'Al-Mokattam');
            },
          ),
          ListTile(
            title: Text('Madinaty'),
            onTap: () {
              Navigator.pop(context, 'Madinaty');
            },
          ),
          ListTile(
            title: Text('Al-Shorouk'),
            onTap: () {
              Navigator.pop(context, 'Al-Shorouk');
            },
          ),
        ],
      ),
    );
  }
}
