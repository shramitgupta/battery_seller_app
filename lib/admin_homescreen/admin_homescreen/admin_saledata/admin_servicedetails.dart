import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminServiceDetail extends StatefulWidget {
  final String documentId;

  const AdminServiceDetail({required this.documentId, Key? key})
      : super(key: key);

  @override
  _AdminServiceDetailState createState() => _AdminServiceDetailState();
}

class _AdminServiceDetailState extends State<AdminServiceDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Admin Service Detail'),
        backgroundColor:
            Colors.redAccent, // Change the app bar background color
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Task')
            .where('product_id', isEqualTo: widget.documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No task found for this product.'));
          }

          final taskDocs = snapshot.data!.docs;
          log(widget.documentId.toString());
          return ListView.builder(
            itemCount: taskDocs.length,
            itemBuilder: (context, index) {
              final taskData = taskDocs[index].data();
              final taskAssignTime = taskData['taskassigntime'] as Timestamp;
              final employeeName = taskData['employee_name'] ?? '';
              final buyerName = taskData['buyer_name'] ?? '';
              final money = taskData['money'] ??
                  0; // Default to 0 if money is not available

              // Format the timestamp to a readable date and time
              final formattedTaskAssignTime =
                  DateFormat('MMM d, y HH:mm').format(taskAssignTime.toDate());

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Assignment Time: $formattedTaskAssignTime',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Change text color
                        ),
                      ),
                      Text(
                        'Employee Name: $employeeName',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Buyer Name: $buyerName',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Money: ₹${money}',
                        style: TextStyle(
                          fontSize: 16,
                          color: money == 0
                              ? Colors.red
                              : Colors
                                  .green, // Red for 0, Green for other values
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
