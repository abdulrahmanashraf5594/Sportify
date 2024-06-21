import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled17/swap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';

class DisplayProductsPage extends StatefulWidget {
  @override
  _DisplayProductsPageState createState() => _DisplayProductsPageState();
}

class _DisplayProductsPageState extends State<DisplayProductsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        title: Text(
          'Swap_sports_tools'.tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          SearchBar(controller: _searchController), // تمرير الـ controller هنا
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var products = snapshot.data!.docs;

                var filteredProducts = products.where((product) {
                  var productName = product['name'].toString().toLowerCase();
                  var searchQuery = _searchController.text.toLowerCase();
                  return productName.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    List<dynamic>? imageUrls = product['imageUrls'];
                    return ProductCard(product: product, imageUrls: imageUrls);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        backgroundColor: Color.fromARGB(255, 41, 169, 92),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}

// إضافة الـ SearchBar مع controller
class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SearchBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    Color textColor =
        themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: TextFormField(
                controller: controller, // استخدام الـ controller هنا
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
                style: TextStyle(color: textColor),
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<dynamic>? imageUrls;

  const ProductCard({Key? key, required this.product, this.imageUrls})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrls != null)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imageUrls!.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    imageUrls![index],
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'name'.tr + ' : ${product['name']}'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('description'.tr + ' ${product['description']}'.tr),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('location'.tr + ' : ${product['address']}'.tr),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Contact_Seller'.tr),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            launchWhatsApp(context, number: product['phone']);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 41, 169, 92),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.whatsapp,
                                size: 32,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text('whatsApp'.tr),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            launchPhoneCall(context, number: product['phone']);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 41, 169, 92),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone),
                              SizedBox(width: 5),
                              Text('call'.tr),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 41, 169, 92),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone),
                SizedBox(width: 5),
                Text('Contact_Seller'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> launchWhatsApp(BuildContext context,
      {required String number}) async {
    // استخدام Intent لفتح تطبيق واتساب على أنظمة Android
    final url = "https://wa.me/+2$number";
    final whatsappUrl = "whatsapp://send?phone=+2$number";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      // إذا فشل استخدام whatsappUrl، استخدم الرابط العادي
      await launch(url);
    }
  }

  Future<void> launchPhoneCall(BuildContext context,
      {required String number}) async {
    final phoneCallUrl = "tel:$number";
    if (await canLaunch(phoneCallUrl)) {
      await launch(phoneCallUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make a phone call to this number: $number'),
        ),
      );
    }
  }
}
