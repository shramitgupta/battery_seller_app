import 'dart:developer';

import 'package:battery_service_app/admin_homescreen/admin_homescreen/admin_saledata/admin_servicedetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleDetailsPage extends StatefulWidget {
  final String saleId;
  final String? buyerName;
  final String? phoneNo;
  final String? area;
  final String? address;

  const SaleDetailsPage({
    Key? key,
    required this.saleId,
    this.buyerName,
    this.phoneNo,
    this.area,
    this.address,
  }) : super(key: key);

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Flag to track whether the sale details have been updated
  bool detailsUpdated = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the current data
    buyerNameController.text = widget.buyerName ?? '';
    phoneNoController.text = widget.phoneNo ?? '';
    areaController.text = widget.area ?? '';
    addressController.text = widget.address ?? '';
  }

  Future<void> updateSaleDetails() async {
    if (_formKey.currentState!.validate()) {
      // Update the sale details in Firestore
      await _firestore.collection('saledata').doc(widget.saleId).update({
        'buyer_name': buyerNameController.text,
        'phone_no': phoneNoController.text,
        'area': areaController.text,
        'address': addressController.text,
      });

      // Set the detailsUpdated flag to true to notify the user
      setState(() {
        detailsUpdated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of your code
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    // Define a function to show an Edit Sale Details dialog
    void showEditDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Sale Details'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: buyerNameController,
                    decoration: InputDecoration(labelText: 'Buyer Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Buyer name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNoController,
                    decoration: InputDecoration(labelText: 'Phone No'),
                    // Add validation as needed
                  ),
                  TextFormField(
                    controller: areaController,
                    decoration: InputDecoration(labelText: 'Area'),
                    // Add validation as needed
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                    // Add validation as needed
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  updateSaleDetails();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }

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
                    Text(
                      'Address: ${widget.address ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: showEditDialog, // Show the Edit dialog
                      child: Text('Edit'),
                    ),
                    if (detailsUpdated)
                      Text('Details Updated Successfully',
                          style: TextStyle(
                            color: Colors.green,
                          )),
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
                      final documentId = productDocs[index].id;
                      // Convert the Timestamp to a DateTime
                      final purchaseDateTime = purchaseDate.toDate();
                      final formattedDate =
                          purchaseDateTime.toLocal().toString().split(' ')[0];

                      return GestureDetector(
                        onTap: () {
                          log('dd   ' + documentId.toString());

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminServiceDetail(documentId: documentId),
                            ),
                          );
                        },
                        child: Card(
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
