import 'package:battery_service_app/button/submit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSalesForm extends StatefulWidget {
  const AdminSalesForm({Key? key}) : super(key: key);

  @override
  State<AdminSalesForm> createState() => _AdminSalesFormState();
}

class _AdminSalesFormState extends State<AdminSalesForm> {
  TextEditingController mfdController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController nextServiceController = TextEditingController();
  TextEditingController buyernameController = TextEditingController();
  TextEditingController phonenoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController productnameController = TextEditingController();

  bool _isUploading = false;
  String _uploadMessage = '';

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
        productnameController.text.isEmpty ||
        mfdController.text.isEmpty ||
        purchaseDateController.text.isEmpty ||
        nextServiceController.text.isEmpty) {
      _showSnackbar('Please fill in all required fields.');
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

        // Upload data to Firestore (replace with actual Firebase Firestore code)
        await FirebaseFirestore.instance.collection('saledata').add({
          'buyer_name': buyernameController.text,
          'phone_no': phoneNumber,
          'address': addressController.text,
          'area': areaController.text,
          'product_name': productnameController.text,
          'mfd': mfdController.text,
          'purchase_date': purchaseDateController.text,
          'next_service': nextServiceController.text,
        });

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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * widthRatio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20 * heightRatio,
                ),
                const Text(
                  'Buyer  Name',
                  style: TextStyle(
                    color: Color(0xFF260446),
                    fontSize: 14,
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
                const Text(
                  'Phone No',
                  style: TextStyle(
                    color: Color(0xFF260446),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 0,
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
                const Text(
                  'Address',
                  style: TextStyle(
                    color: Color(0xFF260446),
                    fontSize: 14,
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
                    fontSize: 16,
                  ),
                  maxLines: 4,
                ),
                SizedBox(
                  height: 5 * heightRatio,
                ),
                const Text(
                  'Area',
                  style: TextStyle(
                    color: Color(0xFF260446),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 0,
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
                const Text(
                  'Product Name',
                  style: TextStyle(
                    color: Color(0xFF260446),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 0,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MFD',
                            style: TextStyle(
                              color: Color(0xFF260446),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
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
                              enabledBorder: OutlineInputBorder(
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
                      width: 5,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Purchase Date',
                            style: TextStyle(
                              color: Color(0xFF260446),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          SizedBox(
                            height: 5,
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
                      width: 5,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next Service',
                            style: TextStyle(
                              color: Color(0xFF260446),
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          SizedBox(
                            height: 5,
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _isUploading
                        ? Center(child: CircularProgressIndicator())
                        : ClickableButton1(
                            widthRatio: widthRatio,
                            heightRatio: heightRatio,
                            onPressed: _uploadData,
                            // child: Text('Submit'),
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
