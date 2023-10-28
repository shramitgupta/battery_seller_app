import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDeleteEmployee extends StatefulWidget {
  const AdminDeleteEmployee({Key? key}) : super(key: key);

  @override
  State<AdminDeleteEmployee> createState() => _AdminDeleteEmployeeState();
}

class _AdminDeleteEmployeeState extends State<AdminDeleteEmployee> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _fetchEmployees() {
    FirebaseFirestore.instance.collection('Employee').get().then((snapshot) {
      setState(() {
        employees = snapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _deleteEmployee(String employeeId, String? email) async {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this employee?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                // Delete the employee from the 'Employee' collection
                await FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(employeeId)
                    .delete();

                // Delete the employee from Firebase Authentication using their email
                if (email != null) {
                  try {
                    await _auth.signInWithEmailAndPassword(
                        email: email, password: 'your_password');
                    await _auth.currentUser!.delete();
                  } catch (e) {
                    print(
                        'Error deleting user from Firebase Authentication: $e');
                    // Handle error appropriately
                  }
                }

                // Refresh the employee list
                _fetchEmployees();

                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Delete Employees'),
        centerTitle: true,
      ),
      body: employees.isEmpty
          ? Center(
              child: Text('No employees found for deletion.'),
            )
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employeeData =
                    employees[index].data() as Map<String, dynamic>;
                final employeeName = employeeData['name'] ?? 'Unknown';
                final employeeId = employeeData['email'] ?? 'Unknown';
                final email = employeeData['email'] as String?;

                return ListTile(
                  title: Text(employeeName),
                  subtitle: Text(employeeId),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEmployee(employees[index].id, email);
                    },
                  ),
                );
              },
            ),
    );
  }
}
