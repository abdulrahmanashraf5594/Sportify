import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/payments.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class PlaygroundDetailsPage extends StatelessWidget {
  final Map<String, dynamic> playgroundData;

  const PlaygroundDetailsPage({Key? key, required this.playgroundData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

  
    Color buttonColor = themeProvider.themeMode == ThemeMode.dark
        ? Color.fromARGB(255, 41, 169, 92)
        : Color.fromARGB(255, 115, 113, 113);
    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;

    if (playgroundData == null || playgroundData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error', style: TextStyle(color: textColor)),
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        ),
        body: Center(
          child: Text('No data available.', style: TextStyle(color: textColor)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title:
            Text('playground_details'.tr, style: TextStyle(color: textColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(playgroundData['imageUrl'][0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetail(
                      context,
                      'name:'.tr,
                      playgroundData['name'],
                      textColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(context, 'sport_type'.tr,
                        playgroundData['type'], textColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDetail(
                          context,
                          'description'.tr,
                          playgroundData['stadiumDetails'],
                          textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetail(
                      context,
                      'open_time'.tr,
                      playgroundData['openTime'],
                      textColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(
                      context,
                      'close_time'.tr,
                      playgroundData['closeTime'],
                      textColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetail(context, 'price'.tr,
                        playgroundData['price'], textColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(context, 'lockers'.tr,
                        playgroundData['lockers'], textColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            _launchGoogleMaps(playgroundData['location']);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              buttonColor,
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(double.infinity, 55)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.location_on, color: textColor),
                          label: Text(
                            'view_location_on_google_maps'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _bookPlayground(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    buttonColor,
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.infinity, 55),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: textColor,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'book_playground'.tr,
                      style: TextStyle(fontSize: 18, color: textColor),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, String label, dynamic data, Color textColor) {
    if (data == null) {
      return Container();
    }
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color expandedColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: expandedColor,
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
            label,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          SizedBox(height: 16),
          Text(
            data,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  void _launchGoogleMaps(String location) async {
    final url = location; // Using the full URL directly
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _bookPlayground(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VodafonePlayground()),
    );
  }
}
