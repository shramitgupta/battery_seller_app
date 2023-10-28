import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AdminDeleteCustomer extends StatefulWidget {
  const AdminDeleteCustomer({Key? key}) : super(key: key);

  @override
  State<AdminDeleteCustomer> createState() => _AdminDeleteCustomerState();
}

class _AdminDeleteCustomerState extends State<AdminDeleteCustomer> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  List<QueryDocumentSnapshot> filteredCustomers = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchSubject
        .debounceTime(
            Duration(milliseconds: 300)) // Debounce for smoother searching
        .distinct() // Avoid duplicate queries
        .switchMap((query) {
      return FirebaseFirestore.instance
          .collection('saledata')
          .where('buyer_name',
              isGreaterThanOrEqualTo: query, isLessThan: query + 'z')
          .snapshots();
    }).listen((snapshot) {
      setState(() {
        isSearching = true;
        filteredCustomers = snapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more items or implement pagination if necessary
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    // Show a dialog to confirm deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this customer?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Perform the deletion
                FirebaseFirestore.instance
                    .collection('saledata')
                    .doc(customerId)
                    .delete()
                    .then((value) {
                  // Close the dialog
                  Navigator.of(context).pop();
                  // Refresh the customer list
                  _searchSubject.add(_searchController.text); // Trigger search
                }).catchError((error) {
                  print("Failed to delete customer: $error");
                  // Handle error appropriately
                });
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
        backgroundColor: Colors.redAccent,
        title: Text('Delete Customers'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by buyer name or phone number',
              ),
              onChanged: (value) {
                _searchSubject.add(value); // Trigger search
              },
            ),
          ),
          isSearching
              ? Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return ListTile(
                        title: Text(customer['buyer_name'] ?? 'Unknown'),
                        subtitle: Text(customer['phone_no'] ?? 'Unknown'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteCustomer(customer.id);
                          },
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Text('Start searching by buyer name '),
                ),
        ],
      ),
    );
  }
}
