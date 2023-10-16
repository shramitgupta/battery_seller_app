import 'package:battery_service_app/Auth/Admin_auth/adminlogin.dart';
import 'package:battery_service_app/employee_homescreen/employeee_taskdetailspage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('Task');

  void logOut() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Log Out"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _auth.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                // Replace with your login page
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AdminLogin()));
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
        backgroundColor: Colors.red[300],
        title: Text(
          "Employee",
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logOut,
            icon: Icon(
              Icons.logout,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksCollection
            .where('employee_id', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tasks found.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return TaskCard(data: data, documentId: document.id);
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;

  TaskCard({required this.data, required this.documentId});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsPage(
                  data: widget.data,
                  documentId: widget.documentId,
                  context: context),
            ),
          );
        },
        child: ListTile(
          title: Text(widget.data['buyer_name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${widget.data['address']}'),
              Text('Area: ${widget.data['area']}'),
              Text('Phone: ${widget.data['phone_no']}'),
            ],
          ),
        ),
      ),
    );
  }
}
