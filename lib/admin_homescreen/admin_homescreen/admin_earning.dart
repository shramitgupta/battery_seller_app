import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                shape: const StadiumBorder(),
              ),
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

                List<Widget> earningWidgets = [];

                for (var taskDoc in taskDocs) {
                  final taskData = taskDoc.data();
                  final taskAssignTime =
                      (taskData['taskassigntime'] as Timestamp?)?.toDate();
                  final money = (taskData['money'] as num?)?.toDouble();
                  final taskName =
                      (taskData['buyer_name'] as String?) ?? 'No Name';

                  if (taskAssignTime != null && money != null) {
                    if (selectedPeriod == 'Daily' &&
                        _isSameDay(taskAssignTime, selectedDate)) {
                      totalEarnings += money;
                      earningWidgets.add(EarningTile(
                        name: taskName,
                        date: taskAssignTime,
                        amount: money,
                      ));
                    } else if (selectedPeriod == 'Weekly' &&
                        _isSameWeek(taskAssignTime, selectedDate)) {
                      totalEarnings += money;
                      earningWidgets.add(EarningTile(
                        name: taskName,
                        date: taskAssignTime,
                        amount: money,
                      ));
                    } else if (selectedPeriod == 'Monthly' &&
                        _isSameMonth(taskAssignTime, selectedDate)) {
                      totalEarnings += money;
                      earningWidgets.add(EarningTile(
                        name: taskName,
                        date: taskAssignTime,
                        amount: money,
                      ));
                    }
                  }
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView(children: earningWidgets),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: EarningsCard(
                        title: 'Total Earnings',
                        earnings: totalEarnings,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays >= 0 &&
        date1.difference(date2).inDays < 7;
  }

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

class EarningTile extends StatelessWidget {
  final String name;
  final DateTime date;
  final double amount;

  EarningTile({
    required this.name,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(
        'Date: ${date.day}/${date.month}/${date.year}, Amount: ₹${amount.toStringAsFixed(2)}',
      ),
    );
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
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
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
