import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerInformationPage extends StatefulWidget {
  final String buyerName;
  final String address;
  final String area;
  final String phoneNo;

  BuyerInformationPage({
    Key? key,
    required this.buyerName,
    required this.address,
    required this.area,
    required this.phoneNo,
  }) : super(key: key);

  @override
  _BuyerInformationPageState createState() => _BuyerInformationPageState();
}

class _BuyerInformationPageState extends State<BuyerInformationPage> {
  String? selectedEmployee;
  final List<Employee> employees = [];
  Employee? selectedEmployeeData;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  void fetchEmployees() async {
    QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    setState(() {
      employees.clear();
      for (QueryDocumentSnapshot document in employeeSnapshot.docs) {
        employees.add(Employee(
          id: document.id,
          name: document['name'] ?? 'Unknown Employee',
        ));
      }
    });
  }

  void createTask() async {
    if (selectedEmployeeData != null) {
      // Create a new task in the "Task" collection
      await FirebaseFirestore.instance.collection('Task').add({
        'buyer_name': widget.buyerName,
        'address': widget.address,
        'area': widget.area,
        'phone_no': widget.phoneNo,
        'employee_id': selectedEmployeeData?.id,
      });

      // Show a snackbar to indicate the task creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task created successfully.'),
        ),
      );
    } else {
      // Show an error message if no employee is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an employee.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Text(
              'Assign Work To:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            _buildEmployeeDropdown(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createTask,
              child: Text('Create Task'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
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