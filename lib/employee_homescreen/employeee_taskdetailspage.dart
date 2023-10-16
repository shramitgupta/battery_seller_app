import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;
  final BuildContext context;

  TaskDetailsPage({
    required this.data,
    required this.documentId,
    required this.context,
  });

  void updateStatus(BuildContext context, String status) {
    FirebaseFirestore.instance
        .collection('Task')
        .doc(documentId)
        .update({'status': status}).then((_) {
      Navigator.of(context).pop(); // Close the dialog
    }).catchError((error) {
      print('Error updating status: $error');
      Navigator.of(context).pop(); // Close the dialog
    });
  }

  void showConfirmationDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm $status?'),
          content: Text('Are you sure you want to $status this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(status),
              onPressed: () {
                updateStatus(context, status);
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
        title: Text('Task Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Buyer Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['buyer_name'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['address'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text(
                    'Area',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['area'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text(
                    'Phone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['phone_no'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Divider(),
                if (data['status'] == 'Task Assigned')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Accepted');
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        child: Text('Accept'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Reject');
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        child: Text('Reject'),
                      ),
                    ],
                  ),
                if (data['status'] == 'Accepted')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Reached Site');
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.orange),
                        child: Text('Reached Site'),
                      ),
                    ],
                  ),
                if (data['status'] == 'Reached Site')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Done');
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        child: Text('Done'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
