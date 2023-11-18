import 'package:battery_service_app/admin_homescreen/admin_homescreen/admin_update/admin_taskdetails.dart';
import 'package:battery_service_app/employee_homescreen/employeee_taskdetailspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminTaskUpdate extends StatefulWidget {
  const AdminTaskUpdate({super.key});

  @override
  State<AdminTaskUpdate> createState() => _AdminTaskUpdateState();
}

class _AdminTaskUpdateState extends State<AdminTaskUpdate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('Task');
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksCollection.snapshots(),
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
    final status = widget.data['status'];

    // Determine the background color based on the status
    Color tileColor = status == 'Done' ? Colors.green : Colors.white;

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      color: tileColor, // Set the background color here
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminTaskDetailsPage(
                data: widget.data,
                documentId: widget.documentId,
                context: context,
              ),
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
