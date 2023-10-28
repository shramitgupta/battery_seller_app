import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEmployeePerformance extends StatefulWidget {
  const AdminEmployeePerformance({Key? key}) : super(key: key);

  @override
  State<AdminEmployeePerformance> createState() =>
      _AdminEmployeePerformanceState();
}

class _AdminEmployeePerformanceState extends State<AdminEmployeePerformance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Employee Performance'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Employee').snapshots(),
        builder: (context, employeeSnapshot) {
          if (employeeSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (employeeSnapshot.hasError) {
            return Center(child: Text('Error: ${employeeSnapshot.error}'));
          }
          if (!employeeSnapshot.hasData ||
              employeeSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('No employees found.'));
          }

          final employeeDocs = employeeSnapshot.data!.docs;

          return ListView.builder(
            itemCount: employeeDocs.length,
            itemBuilder: (context, index) {
              final employeeDoc = employeeDocs[index];

              return EmployeePerformanceCard(employeeDoc);
            },
          );
        },
      ),
    );
  }
}

class EmployeePerformanceCard extends StatelessWidget {
  final QueryDocumentSnapshot employeeDoc;

  EmployeePerformanceCard(this.employeeDoc);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? employeeData =
        employeeDoc.data() as Map<String, dynamic>?;

    if (employeeData == null) {
      return SizedBox.shrink();
    }

    final employeeId = employeeDoc.id;
    final employeeName = employeeData['name'] as String?;

    if (employeeName == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employeeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Task')
                    .where('employee_id', isEqualTo: employeeId)
                    .snapshots(),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (taskSnapshot.hasError) {
                    return Text('Error: ${taskSnapshot.error}');
                  }

                  if (taskSnapshot.hasData) {
                    final taskDocs = taskSnapshot.data!.docs;
                    int totalTasksCompleted = taskDocs.length;
                    double totalEarnings = 0;

                    for (var taskDoc in taskDocs) {
                      final taskData = taskDoc.data();
                      totalEarnings += (taskData['money'] as num).toDouble();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total Earnings: ₹${totalEarnings.toStringAsFixed(2)}'),
                        Text('Total Tasks Completed: $totalTasksCompleted'),
                      ],
                    );
                  }

                  return Text('No tasks found for this employee.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
