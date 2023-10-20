import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEarning extends StatefulWidget {
  const AdminEarning({Key? key}) : super(key: key);

  @override
  State<AdminEarning> createState() => _AdminEarningState();
}

class _AdminEarningState extends State<AdminEarning> {
  DateTime selectedDate = DateTime.now(); // Initially, show earnings for today
  String selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Earnings'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
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
          ListTile(
            title: Text(
              'Selected Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: DropdownButton(
              value: selectedPeriod,
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value.toString();
                });
              },
              items: <String>['Daily', 'Weekly', 'Monthly']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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

                for (var taskDoc in taskDocs) {
                  final taskData = taskDoc.data();
                  final taskAssignTime =
                      (taskData['taskassigntime'] as Timestamp).toDate();
                  final money = (taskData['money'] as num).toDouble();

                  if (selectedPeriod == 'Daily' &&
                      _isSameDay(taskAssignTime, selectedDate)) {
                    totalEarnings += money;
                  } else if (selectedPeriod == 'Weekly' &&
                      _isSameWeek(taskAssignTime, selectedDate)) {
                    totalEarnings += money;
                  } else if (selectedPeriod == 'Monthly' &&
                      _isSameMonth(taskAssignTime, selectedDate)) {
                    totalEarnings += money;
                  }
                }

                return AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EarningsCard(
                        title: 'Total Earnings',
                        earnings: totalEarnings,
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

  // Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if two dates are in the same week
  bool _isSameWeek(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays >= 0 &&
        date1.difference(date2).inDays < 7;
  }

  // Check if two dates are in the same month
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
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
