import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/main.dart';
import 'package:untitled17/screens/vod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class PlaygroundDetailsPage extends StatelessWidget {
  final Map<String, dynamic> playgroundData;

  const PlaygroundDetailsPage({Key? key, required this.playgroundData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color buttonColor = themeProvider.themeMode == ThemeMode.dark
        ? Color.fromARGB(255, 41, 169, 92)
        : Color.fromARGB(255, 115, 113, 113);
    Color textColor = themeProvider.themeMode == ThemeMode.dark ? Colors.grey[200]! : Colors.black;
    if (playgroundData == null || playgroundData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('No data available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text('playground_details'.tr),
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
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(context, 'sport_type'.tr, playgroundData['type']),
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
                    child: _buildDetail(context, 'open_time'.tr, playgroundData['openTime']),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(context, 'close_time'.tr, playgroundData['closeTime']),
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
                    child: _buildDetail(context, 'price'.tr, playgroundData['price']),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetail(context, 'lockers'.tr, playgroundData['lockers']),
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
                              Color.fromARGB(255, 41, 169, 92),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 55)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.location_on, color: Colors.white),
                          label: Text(
                            'view_location_on_google_maps'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
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
                  // تأكد من أن playgroundData يحتوي على 'stadium_id'
                  var stadiumId = playgroundData['stadium_id'];
                  if (stadiumId != null) {
                    _bookPlayground(context, stadiumId);
                  } else {
                    // Handle the null case, maybe show an error message
                    print('Stadium ID is null');
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 41, 169, 92),
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
                      color: Colors.white,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'book_playground'.tr,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              )

            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context ,String label, dynamic data) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    Color textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.grey[200]!
        : Colors.black;
    Color cardColor = themeProvider.themeMode == ThemeMode.dark
        ? const Color.fromARGB(255, 0, 0, 0)!
        : const Color.fromARGB(255, 238, 238, 238);
    if (data == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:textColor ),
          ),
          SizedBox(height: 16),
          Text(
            data,
            style: TextStyle(fontSize: 16,color:textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(String label, String location) {
    return TextButton(
      onPressed: () {
        _launchGoogleMaps(location);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  _launchGoogleMaps(String location) async {
    final url = location; // Using the full URL directly
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _bookPlayground(BuildContext context, String? stadiumId) {
    if (stadiumId == null) {
      // Handle the null case, maybe show an error message
      print('Cannot navigate to booking page without a stadium ID');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VodafonePlayground(stadiumId: stadiumId),
      ),
    );
  }



}