import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEarning extends StatefulWidget {
  const AdminEarning({Key? key}) : super(key: key);

  @override
  State<AdminEarning> createState() => _AdminEarningState();
}

class _AdminEarningState extends State<AdminEarning> {
  DateTime selectedDate = DateTime.now(); // Initially, show earnings for today

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Earnings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Selected Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Task').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No earnings found.'));
                }

                final taskDocs = snapshot.data!.docs;

                double totalEarnings = 0;
                double dailyEarnings = 0;

                for (var taskDoc in taskDocs) {
                  final taskData = taskDoc.data();
                  final taskAssignTime =
                      (taskData['taskassigntime'] as Timestamp).toDate();
                  final money = (taskData['money'] as int).toDouble();

                  totalEarnings += money;

                  if (_isSameDay(taskAssignTime, selectedDate)) {
                    dailyEarnings += money;
                  }
                }

                return AnimatedContainer(
                  duration: Duration(seconds: 1), // Example animation duration
                  curve: Curves.easeInOut, // Example animation curve
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EarningsCard(
                        title: 'Total Earnings',
                        earnings: totalEarnings,
                      ),
                      EarningsCard(
                        title: 'Daily Earnings',
                        earnings: dailyEarnings,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class EarningsCard extends StatelessWidget {
  final String title;
  final double earnings;

  EarningsCard({required this.title, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${earnings.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
