import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTodaysWorks extends StatefulWidget {
  const AdminTodaysWorks({Key? key});

  @override
  State<AdminTodaysWorks> createState() => _AdminTodaysWorksState();
}

class _AdminTodaysWorksState extends State<AdminTodaysWorks> {
  final CollectionReference saleDataCollection =
      FirebaseFirestore.instance.collection('saledata');

  List<Product> todaysProducts = [];

  @override
  void initState() {
    super.initState();
    fetchTodaysProducts();
  }

  Future<void> fetchTodaysProducts() async {
    log('1: Fetching todays products');
    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(Duration(days: 1));

    QuerySnapshot snapshot = await saleDataCollection.get();

    List<Product> products = [];
    for (var doc in snapshot.docs) {
      QuerySnapshot productDataSnapshot =
          await doc.reference.collection('product_data').get();
      log('2: Fetched ${productDataSnapshot.docs.length} product data documents');
      for (var productDoc in productDataSnapshot.docs) {
        var data = productDoc.data() as Map<String, dynamic>;
        var serviceDateString = data['next_service'] as String;
        DateTime serviceDate = DateTime.parse(serviceDateString);

        if (serviceDate.year == today.year &&
            serviceDate.month == today.month &&
            serviceDate.day == today.day) {
          var product = Product.fromMap(data);
          products.add(product);
        }
      }
    }

    setState(() {
      log("3: Fetched ${products.length} products");
      todaysProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todays Works",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: todaysProducts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todaysProducts[index].productName),
            subtitle: Text('MFD: ${todaysProducts[index].manufacturingDate}'),
          );
        },
      ),
    );
  }
}

class Product {
  final String productName;
  final DateTime? manufacturingDate; // Make manufacturingDate nullable
  final String? nextService; // Make nextService nullable

  Product({
    required this.productName,
    this.manufacturingDate, // Update the field to be nullable
    this.nextService, // Update the field to be nullable
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    final productName = data['product_name'] as String? ?? '';
    final manufacturingDateString = data['mfd'] as String?;
    final nextService =
        data['next_service'] as String?; // Cast to nullable String

    DateTime? manufacturingDateConverted;
    if (manufacturingDateString != null) {
      manufacturingDateConverted = DateTime.parse(manufacturingDateString);
    }

    return Product(
      productName: productName,
      manufacturingDate: manufacturingDateConverted,
      nextService: nextService,
    );
  }
}
