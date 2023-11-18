import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BuyerInformationPage extends StatefulWidget {
  final String buyerName;
  final String address;
  final String area;
  final String phoneNo;
  final String? assignedEmployee;
  final String productDataId;

  BuyerInformationPage({
    Key? key,
    required this.buyerName,
    required this.address,
    required this.area,
    required this.phoneNo,
    this.assignedEmployee,
    required this.productDataId,
  }) : super(key: key);

  @override
  _BuyerInformationPageState createState() => _BuyerInformationPageState();
}

class _BuyerInformationPageState extends State<BuyerInformationPage> {
  String? selectedEmployee;
  final List<Employee> employees = [];
  Employee? selectedEmployeeData;
  String? assignedEmployeeName;
  String status = 'Task Assigned';
  double money = 0;
  String done = '';
  String reason = '';
  DateTime? nextServiceDate;
  final nextServiceDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchAssignedEmployeeName(widget.productDataId);
    fetchNextServiceDate(widget.productDataId);
  }

  Future<void> fetchAssignedEmployeeName(String productDataId) async {
    final taskQuery = await FirebaseFirestore.instance
        .collection('Task')
        .where('product_id', isEqualTo: productDataId)
        .where('status', isEqualTo: status)
        .where('done', isNotEqualTo: 'done')
        .get();

    if (taskQuery.docs.isNotEmpty) {
      final taskData = taskQuery.docs.first.data() as Map<String, dynamic>;
      setState(() {
        assignedEmployeeName = taskData['employee_name'];
      });
    }
  }

  Future<void> fetchNextServiceDate(String productDataId) async {
    final productQuery = await FirebaseFirestore.instance
        .collection('product_data')
        .doc(productDataId)
        .get();

    if (productQuery.exists) {
      final productData = productQuery.data() as Map<String, dynamic>;
      setState(() {
        nextServiceDate = (productData['next_service'] as Timestamp?)?.toDate();
        nextServiceDateController.text =
            nextServiceDate?.toLocal().toString() ?? '';
        reason = productData['next_service_reason'];
      });
    }
  }

  void fetchEmployees() async {
    final employeeQuery =
        await FirebaseFirestore.instance.collection('Employee').get();

    setState(() {
      employees.clear();
      for (QueryDocumentSnapshot document in employeeQuery.docs) {
        employees.add(Employee(
          id: document.id,
          name: document['name'] ?? 'Unknown Employee',
        ));
      }
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to do it yourselves?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                updateDataAndServiceDate();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update product data and next service date
  // Function to update product data and next service date in Firebase
  Future<void> updateDataAndServiceDate() async {
    try {
      // Update next_service_reason in the 'product_data' collection
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service_reason': 'Do it ourselves',
      });

      // Update next_service to the next 6th-month date
      DateTime currentDate = DateTime.now();
      DateTime nextServiceDate =
          DateTime(currentDate.year, currentDate.month + 6, currentDate.day);

      // Update the 'next_service' field in the document
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service': nextServiceDate,
      });

      // Update the UI or handle success as needed
      setState(() {
        nextServiceDateController.text =
            DateFormat('yyyy-MM-dd').format(nextServiceDate);
        reason = 'Do it ourselves';
      });
    } catch (error) {
      // Handle errors here
      print('Error updating data: $error');
    }
  }

  Future<void> _showDateSelectionDialog() async {
    DateTime? selectedDate = DateTime.now();

    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (selectedDate != null) {
      await _showConfirmationDialog2(selectedDate);
    }
  }

  Future<void> _showConfirmationDialog2(DateTime selectedDate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to choose this date for the next service?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes, update'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                updateDataAndServiceDate2(selectedDate);
              },
            ),
          ],
        );
      },
    );
  }

// Function to update product data and next service date in Firebase
  Future<void> updateDataAndServiceDate2(DateTime selectedDate) async {
    try {
      // Update next_service_reason in the 'product_data' collection
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service_reason': 'Not now, later',
      });

      // Update next_service to the selected date
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service': selectedDate,
      });

      // Update the UI or handle success as needed
      setState(() {
        nextServiceDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
        reason = 'Not now, later';
      });
    } catch (error) {
      // Handle errors here
      print('Error updating data: $error');
    }
  }

  Future<void> _showDateSelectionDialog2() async {
    DateTime? selectedDate = DateTime.now();

    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (selectedDate != null) {
      await _showConfirmationDialog3(selectedDate);
    }
  }

  Future<void> _showConfirmationDialog3(DateTime selectedDate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to choose this date for the next service?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes, update'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                updateDataAndServiceDate3(selectedDate);
              },
            ),
          ],
        );
      },
    );
  }

// Function to update product data and next service date in Firebase
  Future<void> updateDataAndServiceDate3(DateTime selectedDate) async {
    try {
      // Update next_service_reason in the 'product_data' collection
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service_reason': 'Call not picked',
      });

      // Update next_service to the selected date
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service': selectedDate,
      });

      // Update the UI or handle success as needed
      setState(() {
        nextServiceDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
        reason = 'Call not picked';
      });
    } catch (error) {
      // Handle errors here
      print('Error updating data: $error');
    }
  }

  Future<void> _showConfirmationDialog4(String reason) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to update the reason to "$reason"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes, update'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                updateNextServiceReason(reason);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateNextServiceReason(String reason) async {
    try {
      // Update next_service_reason in the 'product_data' collection
      await FirebaseFirestore.instance
          .collection('product_data')
          .doc(widget.productDataId)
          .update({
        'next_service_reason': reason,
      });

      // Update the UI or handle success as needed
      setState(() {
        reason = 'Please send';
      });
    } catch (error) {
      // Handle errors here
      print('Error updating data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Buyer Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem("Buyer Name", widget.buyerName),
            _buildInfoItem("Address", widget.address),
            _buildInfoItem("Area", widget.area),
            _buildInfoItem("Phone Number", widget.phoneNo),
            _buildInfoItem(
              "Service Date Change Reason:",
              reason,
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Work To:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                _buildEmployeeDropdown(),
              ],
            ),
            SizedBox(height: 20),
            if (assignedEmployeeName != null)
              Text(
                'Assigned Employee: $assignedEmployeeName',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            if (assignedEmployeeName == null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  shape: const StadiumBorder(),
                ),
                onPressed: createTask,
                child: Text(
                  'Create Task',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  shape: const StadiumBorder(),
                ),
                onPressed: reassignTask,
                child: Text('Reassign Task'),
              ),
            SizedBox(height: 20),
            Text(
              'Next Service Date:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nextServiceDateController,
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Change Date',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Styled buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog();
                    // Handle "Do it ourselves" button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('Do it ourselves',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _showDateSelectionDialog();
                    // Handle "Not now, later" button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('Not now, later',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog4('Please send');
                    // Handle "Please send" button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('Please send',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _showDateSelectionDialog2();
                    // Handle "Call not picked" button click
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text('Call not picked',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDropdown() {
    return DropdownButton<Employee>(
      value: selectedEmployeeData,
      onChanged: (Employee? newValue) {
        setState(() {
          selectedEmployeeData = newValue;
        });
      },
      items: employees.map<DropdownMenuItem<Employee>>((Employee employee) {
        return DropdownMenuItem<Employee>(
          value: employee,
          child: Text(employee.name),
        );
      }).toList(),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
    ]);
  }

  void createTask() async {
    if (selectedEmployeeData != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Task Creation'),
            content: Text('Do you want to create this task?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _uploadTask();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an employee.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void reassignTask() {
    if (selectedEmployeeData != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Reassignment'),
              content: Text('Do you want to reassign this task?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _reassignTask();
                  },
                ),
              ],
            );
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an employee for reassignment.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadTask() async {
    final taskDocRef = await FirebaseFirestore.instance.collection('Task').add({
      'buyer_name': widget.buyerName,
      'address': widget.address,
      'area': widget.area,
      'phone_no': widget.phoneNo,
      'employee_id': selectedEmployeeData?.id,
      'employee_name': selectedEmployeeData?.name,
      'product_id': widget.productDataId,
      'status': status,
      'money': money,
      'taskassigntime': FieldValue.serverTimestamp(),
      'done': done,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task created successfully.'),
      ),
    );
  }

  void _reassignTask() async {
    if (selectedEmployeeData != null) {
      final taskQuery = await FirebaseFirestore.instance
          .collection('Task')
          .where('product_id', isEqualTo: widget.productDataId)
          .where('status', isEqualTo: status)
          .get();

      if (taskQuery.docs.isNotEmpty) {
        final taskDoc = taskQuery.docs.first;
        taskDoc.reference.update({
          'employee_name': selectedEmployeeData?.name,
          'employee_id': selectedEmployeeData?.id,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task reassigned successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task not found for reassignment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextServiceDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != nextServiceDate) {
      final String reason = await askForReason(context);
      if (reason.isNotEmpty) {
        setState(() {
          nextServiceDate = picked;
          nextServiceDateController.text = picked.toLocal().toString();
        });

        FirebaseFirestore.instance
            .collection('product_data')
            .doc(widget.productDataId)
            .update({
          'next_service': Timestamp.fromDate(picked),
          'next_service_reason': reason,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Next Service Date updated successfully.'),
          ),
        );
      }
    }
  }

  Future<String> askForReason(BuildContext context) async {
    String reason = "";

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Reason for Update"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Reason"),
                  onChanged: (value) {
                    reason = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(reason);
                },
                child: Text("Submit"),
              ),
            ],
          );
        });
    return reason;
  }
}

class Employee {
  final String id;
  final String name;

  Employee({
    required this.id,
    required this.name,
  });
}
