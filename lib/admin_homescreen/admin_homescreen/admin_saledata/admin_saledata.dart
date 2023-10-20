import 'package:battery_service_app/admin_homescreen/admin_homescreen/admin_saledata/admin_saledetailpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    home: AdminSaleData(),
  ));
}

class AdminSaleData extends StatefulWidget {
  const AdminSaleData({Key? key}) : super(key: key);

  @override
  State<AdminSaleData> createState() => _AdminSaleDataState();
}

class _AdminSaleDataState extends State<AdminSaleData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _sales = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    final querySnapshot = await _firestore.collection('saledata').get();
    setState(() {
      _sales = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Data'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SaleSearchDelegate(_sales),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _sales.length,
        itemBuilder: (context, index) {
          final sale = _sales[index];
          return Card(
            child: ListTile(
              title: Text('Buyer Name: ${sale['buyer_name'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone No: ${sale['phone_no'] ?? ''}'),
                  Text('Area: ${sale['area'] ?? ''}'),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SaleDetailsPage(
                    saleId: sale.id,
                    buyerName: sale['buyer_name'] as String?,
                    phoneNo: sale['phone_no'] as String?,
                    area: sale['area'] as String?,
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

class SaleSearchDelegate extends SearchDelegate<DocumentSnapshot> {
  final List<DocumentSnapshot> _sales;

  SaleSearchDelegate(this._sales);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, _sales.first); // Assuming `_sales` is not empty
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _sales.where((sale) {
      final buyerName = sale['buyer_name']?.toString() ?? '';
      final phoneNo = sale['phone_no']?.toString() ?? '';
      final area = sale['area']?.toString() ?? '';
      return buyerName.contains(query) ||
          phoneNo.contains(query) ||
          area.contains(query);
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _sales.where((sale) {
      final buyerName = sale['buyer_name']?.toString() ?? '';
      final phoneNo = sale['phone_no']?.toString() ?? '';
      final area = sale['area']?.toString() ?? '';
      return buyerName.contains(query) ||
          phoneNo.contains(query) ||
          area.contains(query);
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<DocumentSnapshot> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final sale = results[index];
        return Card(
          child: ListTile(
            title: Text('Buyer Name: ${sale['buyer_name'] ?? ''}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone No: ${sale['phone_no'] ?? ''}'),
                Text('Area: ${sale['area'] ?? ''}'),
              ],
            ),
            onTap: () {
              close(context, sale);
            },
          ),
        );
      },
    );
  }
}
