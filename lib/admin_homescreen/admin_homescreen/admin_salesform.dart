import 'package:battery_service_app/admin_homescreen/admin_homescreen/admin_alreadyexistes.dart';
import 'package:battery_service_app/button/submit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

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

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    // Initialize the "Purchase Date" with the current date
    purchaseDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Calculate and set the "Next Service" date 6 months from the current date
    DateTime currentDate = DateTime.now();
    DateTime nextServiceDate = currentDate.add(Duration(days: 180));
    nextServiceController.text =
        DateFormat('dd-MM-yyyy').format(nextServiceDate);

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
    setState(() {
      _isLoading = true;
    });

    // Check if the phone number already exists
    if (await _isPhoneNumberExists(phonenoController.text)) {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
      final existingUserDetails =
          await _getExistingUserDetails(phonenoController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminAlreadyExist(
            id: existingUserDetails['sale_id'],
            address: existingUserDetails['address'],
            area: existingUserDetails['area'],
            buyerName: existingUserDetails['buyer_name'],
            phoneNumber: existingUserDetails['phone_no'],
          ),
        ),
      );
    } else {
      // Proceed to the next page or continue with data upload
      _tabController.animateTo(1);

      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
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

  Future<Map<String, dynamic>> _getExistingUserDetails(
      String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('saledata')
          .where('phone_no', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return userData;
      }
    } catch (e) {
      print('Error fetching existing user details: $e');
    }
    return {};
  }

  Future<bool> _isPhoneNumberExists(String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('saledata')
          .where('phone_no', isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
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
      // Parse the date strings into DateTime objects
      DateTime mfdDate = DateTime.parse(mfdController.text);
      DateTime purchaseDate = DateTime.parse(purchaseDateController.text);
      DateTime nextServiceDate = DateTime.parse(nextServiceController.text);

      productDataList.add({
        'product_name': productnameController.text,
        'mfd': mfdDate,
        'purchase_date': purchaseDate,
        'next_service': nextServiceDate,
      });

      setState(() {
        productnameController.clear();
        mfdController.clear();
        // purchaseDateController.clear();
        //nextServiceController.clear();
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            controller: _tabController, // Add this line
            unselectedLabelColor: Colors.white, // Color for unselected tabs
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent,
                  Colors.orangeAccent
                ], // Gradient colors for the selected tab indicator
              ),
              borderRadius: BorderRadius.circular(
                  25), // Rounded corners for the selected tab indicator
              color: Colors
                  .redAccent, // Background color of the selected tab indicator
            ),
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Details",
                    style: TextStyle(
                      color: Colors.white, // Text color for the tab label
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Text weight
                    ),
                  ),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Products",
                    style: TextStyle(
                      color: Colors.white, // Text color for the tab label
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Text weight
                    ),
                  ),
                ),
              ),
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
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _isLoading
                          ? SpinKitCircle(
                              color: Colors.blue, // Loading indicator color
                              size: 50.0, // Loading indicator size
                            )
                          : ClickableButton1(
                              widthRatio: widthRatio,
                              heightRatio: heightRatio,
                              text: 'Next',
                              onPressed: () async {
                                if (validatePage1Fields()) {
                                  // All Page 1 fields are filled, check if the phone number exists
                                  final doesPhoneNumberExist =
                                      await _isPhoneNumberExists(
                                          phonenoController.text);
                                  Map<String, dynamic> existingUserDetails;
                                  if (await _isPhoneNumberExists(
                                      phonenoController.text)) {
                                    existingUserDetails =
                                        await _getExistingUserDetails(
                                            phonenoController.text);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminAlreadyExist(
                                          id: existingUserDetails['sale_id'],
                                          address:
                                              existingUserDetails['address'],
                                          area: existingUserDetails['area'],
                                          buyerName:
                                              existingUserDetails['buyer_name'],
                                          phoneNumber:
                                              existingUserDetails['phone_no'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Proceed to the next page or continue with data upload
                                    _tabController.animateTo(1);
                                  }
                                } else {
                                  _showSnackbar(
                                      'Please fill in all required fields on Page 1.');
                                }
                              },
                            ),
                    ),
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
                  SizedBox(
                    height: 40 * heightRatio,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClickableButton1(
                      heightRatio: heightRatio,
                      widthRatio: widthRatio,
                      text: 'Add Product Data',
                      onPressed: cloneProductFields,
                    ),
                  ),
                  if (productDataList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10 * heightRatio),
                          child: Text(
                            'Added Product Data:',
                            style: TextStyle(
                              color: const Color(0xFF260446),
                              fontSize: 16 * widthRatio * heightRatio,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          height: 300 * heightRatio,
                          child: ListView(
                            children:
                                productDataList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;

                              return Dismissible(
                                key: Key('$index'),
                                onDismissed: (direction) {
                                  // Remove the item from the list
                                  setState(() {
                                    productDataList.removeAt(index);
                                  });
                                },
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  // Display a confirmation dialog
                                  bool isConfirmed = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to delete this item?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              // Cancel the deletion
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Confirm the deletion
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return isConfirmed;
                                },
                                background: Container(
                                  color: Colors
                                      .red, // Background color for delete action
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10 * heightRatio),
                                  child: ListTile(
                                    title: Text(
                                      'Product: ${data['product_name']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16 * widthRatio * heightRatio,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 5 * heightRatio),
                                        Text(
                                          'MFD: ${data['mfd']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                14 * widthRatio * heightRatio,
                                          ),
                                        ),
                                        Text(
                                          'Purchase Date: ${data['purchase_date']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                14 * widthRatio * heightRatio,
                                          ),
                                        ),
                                        Text(
                                          'Next Service: ${data['next_service']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                14 * widthRatio * heightRatio,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
                          : ClickableButton1(
                              widthRatio: widthRatio,
                              heightRatio: heightRatio,
                              text: 'Submit',
                              onPressed: _uploadData,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
