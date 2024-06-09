import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  ProductDetailsPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        backgroundColor: Color.fromARGB(255, 41, 169, 92),

        title: Text('Product Detailsس'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Handle the case where the document does not exist
            return Center(
              child: Text('Product not found'),
            );
          }

          var productDetails = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${productDetails['name']}'),
                Text('Description: ${productDetails['description']}'),
                Text('Price: ${productDetails['price']}'),
                // Add more fields as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
