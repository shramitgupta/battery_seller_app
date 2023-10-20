import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SaleDetailsPage extends StatefulWidget {
  final String saleId;
  final String? buyerName;
  final String? phoneNo;
  final String? area;

  const SaleDetailsPage({
    Key? key,
    required this.saleId,
    this.buyerName,
    this.phoneNo,
    this.area,
  }) : super(key: key);

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: const Text('Sale Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 5,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16 * heightRatio),
                    Text(
                      'Buyer Name: ${widget.buyerName ?? ''}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Phone No: ${widget.phoneNo ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Area: ${widget.area ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder(
                stream: _firestore
                    .collection('product_data')
                    .where('sale_id', isEqualTo: widget.saleId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data found.'));
                  }

                  final productDocs = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: productDocs.length,
                    itemBuilder: (context, index) {
                      final productData = productDocs[index].data();
                      final productName = productData['product_name'] ?? '';
                      final nextService =
                          productData['next_service'] as Timestamp;

                      final purchaseDate =
                          productData['purchase_date'] as Timestamp;
                      final mfd = productData['mfd'] as Timestamp;

                      // Convert the Timestamp to a DateTime
                      final purchaseDateTime = purchaseDate.toDate();
                      final formattedDate =
                          purchaseDateTime.toLocal().toString().split(' ')[0];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Name: $productName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Next Service: ${nextService.toDate().toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Purchase Date: $formattedDate',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'MFD: ${mfd.toDate().toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
