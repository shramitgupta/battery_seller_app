import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSalesForm extends StatefulWidget {
  const AdminSalesForm({Key? key}) : super(key: key);

  @override
  State<AdminSalesForm> createState() => _AdminSalesFormState();
}

class _AdminSalesFormState extends State<AdminSalesForm> {
  TextEditingController buyernameController = TextEditingController();
  TextEditingController phonenoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController productnameController = TextEditingController();
  TextEditingController mfdController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController nextServiceController = TextEditingController();

  List<Map<String, dynamic>> productDataList = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the "Purchase Date" with the current date
    purchaseDateController.text = DateTime.now().toString().substring(0, 10);

    // Calculate and set the "Next Service" date 6 months from the current date
    DateTime currentDate = DateTime.now();
    DateTime nextServiceDate = currentDate.add(Duration(days: 180));
    nextServiceController.text = nextServiceDate.toString().substring(0, 10);
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
      // Query Firestore to check if the phone number already exists
      final existingDocs = await FirebaseFirestore.instance
          .collection('saledata')
          .where('phone_no', isEqualTo: phoneNumber)
          .get();

      // Check if a document with the same phone number already exists
      if (existingDocs.docs.isNotEmpty) {
        _showSnackbar('Phone number already used.');
      } else {
        // Simulate uploading process (replace with actual Firebase Firestore upload)
        await Future.delayed(Duration(seconds: 2));

        // Create a map for the main data
        final mainData = {
          'buyer_name': buyernameController.text,
          'phone_no': phoneNumber,
          'address': addressController.text,
          'area': areaController.text,
        };

        // Create a Firestore document for the main data
        final mainDocRef = await FirebaseFirestore.instance
            .collection('saledata')
            .add(mainData);

        // Create a subcollection for the added product data
        for (final productData in productDataList) {
          await mainDocRef.collection('product_data').add(productData);
        }

        // Set success message
        _showSnackbar('Data uploaded successfully!');

        // Delay for a moment to display the success message
        await Future.delayed(Duration(seconds: 2));

        // Navigate back to the previous screen
        Navigator.pop(context);
      }
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
      ),
      body: Padding(
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
                                mfdController.text =
                                    selectedDate.toString().substring(0, 10);
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
              onPressed: _addProductData,
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
    );
  }

  void _addProductData() {
    // Check if any of the product data fields are empty
    if (productnameController.text.isEmpty ||
        mfdController.text.isEmpty ||
        purchaseDateController.text.isEmpty ||
        nextServiceController.text.isEmpty) {
      _showSnackbar('Please fill in all product data fields.');
    } else {
      // Add the product data to the list
      productDataList.add({
        'product_name': productnameController.text,
        'mfd': mfdController.text,
        'purchase_date': purchaseDateController.text,
        'next_service': nextServiceController.text,
      });

      // Clear the product data input fields
      productnameController.clear();
      mfdController.clear();
      //purchaseDateController.clear();
      // nextServiceController.clear();
    }
  }
}
