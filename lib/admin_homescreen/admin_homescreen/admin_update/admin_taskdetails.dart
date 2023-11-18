import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;
  final BuildContext context;
  AdminTaskDetailsPage({
    required this.data,
    required this.documentId,
    required this.context,
  });

  @override
  _AdminTaskDetailsPageState createState() => _AdminTaskDetailsPageState();
}

class _AdminTaskDetailsPageState extends State<AdminTaskDetailsPage> {
  String status = '';
  double amountInput = 0.0; // To store the inputted amount

  @override
  void initState() {
    status = widget.data['status'];
    super.initState();
  }

  void updateStatus(BuildContext context, String newStatus) {
    if (newStatus == 'Done' && status == 'Reached Site') {
      if (amountInput <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid amount.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      // Calculate the date six months from now
      final DateTime currentDate = DateTime.now();
      final DateTime nextServiceDate = currentDate.add(Duration(days: 6 * 30));

      // Update the 'Task' collection and the 'product_data' collection
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference taskRef = FirebaseFirestore.instance
            .collection('Task')
            .doc(widget.documentId);

        DocumentSnapshot productDataSnapshot = await transaction.get(
            FirebaseFirestore.instance
                .collection('product_data')
                .doc(widget.data['product_id']));

        // Update the 'money' field in the 'Task' collection
        transaction.update(taskRef, {
          'status': newStatus,
          'money': amountInput,
          'done': 'done',
        });

        // Update the 'next_service' field in the 'product_data' collection
        transaction.update(
            FirebaseFirestore.instance
                .collection('product_data')
                .doc(widget.data['product_id']),
            {
              'next_service': nextServiceDate,
            });

        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Pop the current page
      }).catchError((error) {
        print('Error updating status: $error');
        Navigator.of(context).pop(); // Close the dialog
      });
    } else {
      FirebaseFirestore.instance
          .collection('Task')
          .doc(widget.documentId)
          .update({
        'status': newStatus,
      }).then((_) {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Pop the current page
      }).catchError((error) {
        print('Error updating status: $error');
        Navigator.of(context).pop(); // Close the dialog
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
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
                    widget.data['buyer_name'],
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
                    widget.data['address'],
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
                    widget.data['area'],
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
                    widget.data['phone_no'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Divider(),
                if (status == 'Task Assigned')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Accepted');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text('Accept'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Reject');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text('Reject'),
                      ),
                    ],
                  ),
                if (status == 'Accepted')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Reached Site');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: Text('Reached Site'),
                      ),
                    ],
                  ),
                if (status == 'Reached Site')
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Enter amount received:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            amountInput = double.tryParse(value) ?? 0.0;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(context, 'Done');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
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
}
