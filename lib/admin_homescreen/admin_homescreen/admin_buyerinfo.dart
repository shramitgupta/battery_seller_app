import 'package:flutter/material.dart';

class BuyerInformationPage extends StatelessWidget {
  final String buyerName;
  final String address;
  final String area;
  final String phoneNo;

  const BuyerInformationPage({
    Key? key,
    required this.buyerName,
    required this.address,
    required this.area,
    required this.phoneNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buyer Name:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(buyerName, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text(
              'Address:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(address, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text(
              'Area:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(area, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text(
              'Phone Number:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(phoneNo, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
