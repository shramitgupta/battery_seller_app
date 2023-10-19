import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchAssignedEmployeeName(widget.productDataId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Information'),
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
                onPressed: createTask,
                child: Text('Create Task'),
              )
            else
              ElevatedButton(
                onPressed: reassignTask,
                child: Text('Reassign Task'),
              )
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
        },
      );
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
}

class Employee {
  final String id;
  final String name;

  Employee({
    required this.id,
    required this.name,
  });
}
