import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSalesForm extends StatefulWidget {
  const AdminSalesForm({Key? key}) : super(key: key);

  @override
  State<AdminSalesForm> createState() => _AdminSalesFormState();
}

class _AdminSalesFormState extends State<AdminSalesForm>
    with SingleTickerProviderStateMixin {
  TextEditingController buyernameController = TextEditingController();
  TextEditingController phonenoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController productnameController = TextEditingController();
  TextEditingController mfdController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController nextServiceController = TextEditingController();

  List<Map<String, dynamic>> productDataList = [];
  int productFieldCount = 1;
  bool _isUploading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize the "Purchase Date" with the current date
    purchaseDateController.text = DateTime.now().toString().substring(0, 10);

    // Calculate and set the "Next Service" date 6 months from the current date
    DateTime currentDate = DateTime.now();
    DateTime nextServiceDate = currentDate.add(Duration(days: 180));
    nextServiceController.text = nextServiceDate.toString().substring(0, 10);

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool validatePage1Fields() {
    if (buyernameController.text.isEmpty ||
        phonenoController.text.isEmpty ||
        addressController.text.isEmpty ||
        areaController.text.isEmpty) {
      return false; // At least one required field is empty
    }
    return true; // All required fields are filled
  }

  Future<void> _uploadData() async {
    // Check if any of the required fields are empty
    if (buyernameController.text.isEmpty ||
        phonenoController.text.isEmpty ||
        addressController.text.isEmpty ||
        areaController.text.isEmpty ||
        productDataList.isEmpty) {
      _showSnackbar(
          'Please fill in all required fields and add at least one set of product data.');
      return;
    }

    // Set uploading state
    setState(() {
      _isUploading = true;
    });

    final phoneNumber = phonenoController.text;

    try {
      // Generate a new document reference for the main sale data
      final mainDocRef =
          FirebaseFirestore.instance.collection('saledata').doc();

      // Get the generated UID
      final saleUID = mainDocRef.id;

      // Create a map for the main sale data with the UID
      final mainData = {
        'sale_id': saleUID,
        'buyer_name': buyernameController.text,
        'phone_no': phoneNumber,
        'address': addressController.text,
        'area': areaController.text,
      };

      // Set the main sale data in the document with the generated UID
      await mainDocRef.set(mainData);

      // Create a new collection for product data using the same UID
      for (final productData in productDataList) {
        // Generate a new document reference for each product data
        final productDocRef =
            FirebaseFirestore.instance.collection('product_data').doc();

        // Set the product data in the document
        await productDocRef.set({
          'sale_id': saleUID,
          'product_name': productData['product_name'],
          'mfd': productData['mfd'],
          'purchase_date': productData['purchase_date'],
          'next_service': productData['next_service'],
        });
      }

      // Set success message
      _showSnackbar('Data uploaded successfully!');

      // Delay for a moment to display the success message
      await Future.delayed(const Duration(seconds: 2));

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that occur during upload
      _showSnackbar('Error uploading data: $e');
    } finally {
      // Reset the uploading state
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void cloneProductFields() {
    if (productnameController.text.isNotEmpty &&
        mfdController.text.isNotEmpty &&
        purchaseDateController.text.isNotEmpty &&
        nextServiceController.text.isNotEmpty) {
      productDataList.add({
        'product_name': productnameController.text,
        'mfd': mfdController.text,
        'purchase_date': purchaseDateController.text,
        'next_service': nextServiceController.text,
      });

      setState(() {
        productnameController.clear();
        mfdController.clear();
        productFieldCount++;
      });
    } else {
      _showSnackbar('Please fill in all product data fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        title: Text(
          "Sale Form",
          style: TextStyle(
            fontSize: 26 * widthRatio * heightRatio,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Page 1'),
            Tab(text: 'Page 2'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Page 1
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * widthRatio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20 * heightRatio,
                ),
                Text(
                  'Buyer Name',
                  style: TextStyle(
                    color: const Color(0xFF260446),
                    fontSize: 14 * widthRatio * heightRatio,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                TextFormField(
                  controller: buyernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                Text(
                  'Phone No',
                  style: TextStyle(
                    color: const Color(0xFF260446),
                    fontSize: 14 * widthRatio * heightRatio,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                TextFormField(
                  controller: phonenoController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    counter: const Offstage(),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                Text(
                  'Address',
                  style: TextStyle(
                    color: const Color(0xFF260446),
                    fontSize: 14 * widthRatio * heightRatio,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16 * widthRatio * heightRatio,
                  ),
                  maxLines: 4,
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                Text(
                  'Area',
                  style: TextStyle(
                    color: const Color(0xFF260446),
                    fontSize: 14 * widthRatio * heightRatio,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                TextFormField(
                  controller: areaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Add a function to validate Page 1 fields

// Inside your build method
                ElevatedButton(
                  onPressed: () {
                    if (validatePage1Fields()) {
                      // All Page 1 fields are filled, switch to Page 2
                      _tabController.animateTo(
                          1); // 1 corresponds to the second tab (Page 2)
                    } else {
                      _showSnackbar(
                          'Please fill in all required fields on Page 1.');
                    }
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ),

          // Page 2
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * widthRatio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5 * heightRatio,
                ),
                Text(
                  'Product Name',
                  style: TextStyle(
                    color: const Color(0xFF260446),
                    fontSize: 14 * widthRatio * heightRatio,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                TextFormField(
                  controller: productnameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MFD',
                            style: TextStyle(
                              color: const Color(0xFF260446),
                              fontSize: 14 * widthRatio * heightRatio,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: mfdController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  setState(() {
                                    mfdController.text = selectedDate
                                        .toString()
                                        .substring(0, 10);
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5 * widthRatio,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Purchase Date',
                            style: TextStyle(
                              color: const Color(0xFF260446),
                              fontSize: 14 * widthRatio * heightRatio,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 5 * widthRatio,
                          ),
                          TextFormField(
                            controller: purchaseDateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5 * widthRatio,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Service',
                            style: TextStyle(
                              color: const Color(0xFF260446),
                              fontSize: 14 * widthRatio * heightRatio,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 5 * widthRatio,
                          ),
                          TextFormField(
                            controller: nextServiceController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Button to add product data
                ElevatedButton(
                  onPressed: cloneProductFields,
                  child: Text('Add Product Data'),
                ),
                // Display added product data
                if (productDataList.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Added Product Data:',
                        style: TextStyle(
                          color: const Color(0xFF260446),
                          fontSize: 14 * widthRatio * heightRatio,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Column(
                        children: productDataList.map((data) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Product: ${data['product_name']}, MFD: ${data['mfd']}, Purchase Date: ${data['purchase_date']}, Next Service: ${data['next_service']}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _isUploading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const CircularProgressIndicator(
                              color: Colors.redAccent,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _uploadData,
                            child: Text('Submit'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
