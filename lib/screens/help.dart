// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/constants.dart';
import 'package:untitled17/main.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('help!'.tr),
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final Uri whatsapp1 = Uri.parse('https://wa.me/+201064841436');
    final Uri mail1 = Uri.parse(
        'mailto:عبدالوهاب@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.');
    final Uri whatsapp2 = Uri.parse('https://wa.me/+201028875594');
    final Uri mail2 = Uri.parse(
        'mailto:abdulrahman.ashraf5594@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.');
    final Uri whatsapp3 = Uri.parse('https://wa.me/+201141260367');
    final Uri mail3 = Uri.parse(
        'mailto:eman.k.mostafa@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.');
    final Uri whatsapp4 = Uri.parse('https://wa.me/+201212026175');
    final Uri mail4 = Uri.parse(
        'mailto:Martinazakaria38@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.');

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'app_information'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developer: Team13'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height *
                              0.6, // ارتفاع نصف ارتفاع الشاشة
                          width: 290, // العرض بعرض الشاشة

                          padding: EdgeInsets.all(30),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 275, // تعيين عرض الصندوق
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 200, 81,
                                        81), // تعيين اللون الأزرق كخلفية
                                    borderRadius: BorderRadius.circular(
                                        20), // تحديد الزوايا المستديرة
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('backend: abdelwahab'),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(whatsapp4);
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: 32,
                                        ),
                                        label: Text('Contact via WhatsApp'),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(mail1);
                                        },
                                        icon: Icon(
                                          Icons.email,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07, // استخدم نسبة مئوية من عرض الشاشة
                                        ),
                                        label: Text('Contact via Email'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 275, // تعيين عرض الصندوق
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // تعيين اللون الأزرق كخلفية
                                    borderRadius: BorderRadius.circular(
                                        20), // تحديد الزوايا المستديرة
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('frontend: abdulrahman'),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(whatsapp4);
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: 32,
                                        ),
                                        label: Text('Contact via WhatsApp'),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(mail2);
                                        },
                                        icon: Icon(
                                          Icons.email,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07, // استخدم نسبة مئوية من عرض الشاشة
                                        ),
                                        label: Text('Contact via Email'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 275, // تعيين عرض الصندوق
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // تعيين اللون الأزرق كخلفية
                                    borderRadius: BorderRadius.circular(
                                        20), // تحديد الزوايا المستديرة
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('frontend: eman'),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(whatsapp4);
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: 32,
                                        ),
                                        label: Text('Contact via WhatsApp'),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(mail3);
                                        },
                                        icon: Icon(
                                          Icons.email,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07, // استخدم نسبة مئوية من عرض الشاشة
                                        ),
                                        label: Text('Contact via Email'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 275, // تعيين عرض الصندوق
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // تعيين اللون الأزرق كخلفية
                                    borderRadius: BorderRadius.circular(
                                        20), // تحديد الزوايا المستديرة
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('frontend: martena'),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(whatsapp4);
                                        },
                                        icon: FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          size: 32,
                                        ),
                                        label: Text('Contact via WhatsApp'),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          launchUrl(mail4);
                                        },
                                        icon: Icon(
                                          Icons.email,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07, // استخدم نسبة مئوية من عرض الشاشة
                                        ),
                                        label: Text('Contact via Email'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.help),
                  label: Text('help'.tr),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showUpdateMessage();
                  },
                  icon: Icon(Icons.update),
                  label: Text('update'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('you_already_have_the_latest_update'.tr),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

launchWhatsApp1() async {
  const url = "https://wa.me/+201064841436";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

launchEmail1() async {
  const emailAddress =
      "mailto:عبدالوهاب@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.";

  if (await canLaunch(emailAddress)) {
    await launch(emailAddress);
  } else {
    throw 'Could not launch $emailAddress';
  }
}

launchWhatsApp2() async {
  const url = "https://wa.me/+201028875594";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

launchEmail2() async {
  const emailAddress =
      "mailto:abdulrahman.ashraf5594@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.";

  if (await canLaunch(emailAddress)) {
    await launch(emailAddress);
  } else {
    throw 'Could not launch $emailAddress';
  }
}

launchWhatsApp3() async {
  const url = "https://wa.me/+201141260367";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

launchEmail3() async {
  const emailAddress =
      "mailto:eman.k.mostafa@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.";

  if (await canLaunch(emailAddress)) {
    await launch(emailAddress);
  } else {
    throw 'Could not launch $emailAddress';
  }
}

launchWhatsApp4() async {
  const url = "https://wa.me/+201212026175";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

launchEmail4() async {
  const emailAddress =
      "mailto:Martinazakaria38@gmail.com?subject=Support&body=Hello,%20I%20need%20assistance.";

  if (await canLaunch(emailAddress)) {
    await launch(emailAddress);
  } else {
    throw 'Could not launch $emailAddress';
  }
}
