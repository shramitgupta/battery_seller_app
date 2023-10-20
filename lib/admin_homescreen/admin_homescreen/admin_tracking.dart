import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTracking extends StatefulWidget {
  const AdminTracking({Key? key}) : super(key: key);

  @override
  State<AdminTracking> createState() => _AdminTrackingState();
}

class _AdminTrackingState extends State<AdminTracking>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Timestamp _startOfDay(DateTime date) {
    return Timestamp.fromDate(DateTime(date.year, date.month, date.day));
  }

  Timestamp _endOfDay(DateTime date) {
    return Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Tracking',
          style: TextStyle(
              color: Colors.white, fontSize: 30 * widthRatio * heightRatio),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Today\'s Tasks'),
            Tab(text: 'Pending Tasks'),
            Tab(text: 'Completed Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Today's Tasks
          // Today's Tasks
          // Today's Tasks
          TaskList(
            query: _firestore
                .collection('Task')
                .where('taskassigntime',
                    isGreaterThanOrEqualTo: _startOfDay(DateTime.now()))
                .where('taskassigntime', isLessThan: _endOfDay(DateTime.now())),
          ),

          // Pending Tasks
          TaskList(
              query:
                  _firestore.collection('Task').where('done', isEqualTo: '')),

          // Completed Tasks
          TaskList(
              query: _firestore
                  .collection('Task')
                  .where('done', isEqualTo: 'done')),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final Query query;

  TaskList({required this.query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs;

        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final taskData = tasks[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 4, // Adjust the elevation for a shadow effect
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Adjust the border radius as desired
              ),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buyer Name: ${taskData['buyer_name']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Buyer Phone No: ${taskData['phone_no']}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Task Assign to: ${taskData['employee_name']}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Status: ${taskData['status']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: taskData['status'] == 'done'
                              ? Colors.green
                              : Colors.red, // Customize color based on status
                        ),
                      ),
                      Text(
                        "Amount Received: ₹${taskData['money']}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
