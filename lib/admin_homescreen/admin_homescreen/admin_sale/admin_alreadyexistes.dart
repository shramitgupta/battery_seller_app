import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAlreadyExist extends StatefulWidget {
  final String address;
  final String area;
  final String buyerName;
  final String phoneNumber;
  final String id;

  AdminAlreadyExist({
    required this.address,
    required this.area,
    required this.buyerName,
    required this.phoneNumber,
    required this.id,
  });

  @override
  State<AdminAlreadyExist> createState() => _AdminAlreadyExistState();
}

class _AdminAlreadyExistState extends State<AdminAlreadyExist> {
  Future<QuerySnapshot?> getProductData(String saleId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('product_data')
        .where('sale_id', isEqualTo: saleId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Details'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildSectionHeader("Buyer Information", Colors.redAccent),
                  Card(
                    elevation: 10,
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildInfoTile(
                            "Buyer Name", widget.buyerName, Icons.person),
                        _buildInfoTile(
                            "Phone Number", widget.phoneNumber, Icons.phone),
                        _buildInfoTile(
                            "Address", widget.address, Icons.location_on),
                        _buildInfoTile(
                            "Area", widget.area, Icons.location_city),
                      ],
                    ),
                  ),
                  _buildSectionHeader("Product Information", Colors.redAccent),
                  FutureBuilder(
                    future: getProductData(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        final productData = snapshot.data as QuerySnapshot;
                        int productNumber = 1;

                        return Column(
                          children: productData.docs.map((doc) {
                            final productName = doc['product_name'];
                            final mfd = doc['mfd'];
                            final purchaseDate = doc['purchase_date'];
                            final nextService = doc['next_service'];

                            final productTitle = "Product $productNumber";
                            productNumber++;

                            return _buildProductCard(
                              productTitle,
                              productName,
                              mfd,
                              purchaseDate,
                              nextService,
                              doc.id,
                            );
                          }).toList(),
                        );
                      } else {
                        return Text(
                          'No related product data found.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddProductDialog(
                id: widget.id,
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      color: color,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildProductCard(
    String sectionTitle,
    String productName,
    Timestamp mfd,
    Timestamp purchaseDate,
    Timestamp nextService,
    String docId,
  ) {
    DateTime mfdDate = mfd.toDate();
    DateTime purchaseDateTime = purchaseDate.toDate();
    DateTime nextServiceDateTime = nextService.toDate();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white70,
      child: Column(
        children: [
          _buildInfoTile(sectionTitle, '', Icons.shopping_basket),
          _buildInfoTile("Product Name", productName, Icons.label),
          _buildInfoTile(
            "Manufacturing Date",
            DateFormat('dd-MM-yyyy').format(mfdDate), // Display only the date
            Icons.date_range,
          ),
          _buildInfoTile(
            "Purchase Date",
            DateFormat('dd-MM-yyyy')
                .format(purchaseDateTime), // Display only the date
            Icons.date_range,
          ),
          _buildInfoTile(
            "Next Service Date",
            DateFormat('dd-MM-yyyy')
                .format(nextServiceDateTime), // Display only the date
            Icons.date_range,
          ),
          ElevatedButton(
            onPressed: () {
              _confirmDeleteDialog(docId); // Show confirmation dialog
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(docId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String docId) {
    FirebaseFirestore.instance.collection('product_data').doc(docId).delete();
    setState(() {});
  }
}

class AddProductDialog extends StatefulWidget {
  final String id;
  AddProductDialog({
    required this.id,
  });
  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late DateTime mfdDate;
  late DateTime purchaseDate;
  late DateTime nextServiceDate;

  @override
  void initState() {
    super.initState();
    mfdDate = DateTime.now();
    purchaseDate = DateTime.now();
    nextServiceDate =
        DateTime.now().add(Duration(days: 180)); // 6 months from today
  }

  @override
  Widget build(BuildContext context) {
    // Create a new instance of TextEditingController
    TextEditingController productNameController = TextEditingController();

    return AlertDialog(
      title: Text('Add Product Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller:
                productNameController, // Set the controller for the product name field
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          ListTile(
            title: Text('Manufacturing Date'),
            subtitle: Text(DateFormat('dd-MM-yyyy').format(mfdDate)),
            onTap: () {
              _selectDate(context, mfdDate, (DateTime date) {
                mfdDate = date;
              });
            },
          ),
          ListTile(
            title: Text('Purchase Date'),
            subtitle: Text(DateFormat('dd-MM-yyyy').format(purchaseDate)),
            onTap: () {
              _selectDate(context, purchaseDate, (DateTime date) {
                purchaseDate = date;
              });
            },
          ),
          ListTile(
            title: Text('Next Service Date'),
            subtitle: Text(DateFormat('dd-MM-yyyy').format(nextServiceDate)),
            onTap: () {
              _selectDate(context, nextServiceDate, (DateTime date) {
                nextServiceDate = date;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            saveProductData(
                widget.id, productNameController.text); // Pass the product name
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  void saveProductData(String id, String productName) async {
    // Get the values from the fields and use them
    String mfdString = DateFormat('dd-MM-yyyy').format(mfdDate);
    String purchaseDateString = DateFormat('dd-MM-yyyy').format(purchaseDate);
    String nextServiceDateString =
        DateFormat('dd-MM-yyyy').format(nextServiceDate);
    String reason = 'Not Changed Yet';
    await FirebaseFirestore.instance.collection('product_data').add({
      'sale_id': id,
      'product_name': productName, // Use the passed product name
      'mfd': Timestamp.fromDate(mfdDate),
      'purchase_date': Timestamp.fromDate(purchaseDate),
      'next_service': Timestamp.fromDate(nextServiceDate),
      'next_service_reason': reason,
    });

    setState(() {});
  }
}
