import 'package:battery_service_app/admin_homescreen/admin_homescreen/admin_buyerinfopage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminTodaysWorks extends StatefulWidget {
  const AdminTodaysWorks({Key? key}) : super(key: key);

  @override
  State<AdminTodaysWorks> createState() => _AdminTodaysWorksState();
}

class _AdminTodaysWorksState extends State<AdminTodaysWorks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Today's Works",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: TodaysWorksList(),
    );
  }
}

class Product {
  final String productName;
  final DateTime nextService;
  final String saleId;
  final DateTime mfd;
  final DateTime purchaseDate;

  Product({
    required this.productName,
    required this.nextService,
    required this.saleId,
    required this.mfd,
    required this.purchaseDate,
  });
}

class TodaysWorksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('product_data').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator()); // Loading indicator
        }

        DateTime today = DateTime.now();
        List<Product> todaysProducts = [];

        snapshot.data!.docs.forEach((doc) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime nextServiceDate =
              (data['next_service'] as Timestamp).toDate();
          String saleId = data['sale_id'] as String;

          var mfd = data['mfd'];
          var purchaseDate = data['purchase_date'];

          var product = Product(
            productName:
                data['product_name'] as String? ?? 'Product Name Not Found',
            nextService: nextServiceDate,
            saleId: saleId,
            mfd: mfd != null
                ? (mfd as Timestamp).toDate()
                : DateTime(2000), // Default MFD
            purchaseDate: purchaseDate != null
                ? (purchaseDate as Timestamp).toDate()
                : DateTime(2000), // Default purchase date
          );

          if (nextServiceDate.year == today.year &&
              nextServiceDate.month == today.month &&
              nextServiceDate.day == today.day) {
            todaysProducts.add(product);
          }
        });

        return ListView.builder(
          itemCount: todaysProducts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: ProductInfoTile(product: todaysProducts[index]),
              onTap: () {
                showBuyerInformation(context, todaysProducts[index],
                    snapshot.data!.docs[index].id);
              },
            );
          },
        );
      },
    );
  }

  Future<void> showBuyerInformation(
      BuildContext context, Product product, String productDataId) async {
    DocumentSnapshot saleDataSnapshot = await FirebaseFirestore.instance
        .collection('saledata')
        .doc(product.saleId)
        .get();
    if (saleDataSnapshot.exists) {
      var data = saleDataSnapshot.data() as Map<String, dynamic>;
      String buyerName = data['buyer_name'] as String;
      String address = data['address'] as String;
      String area = data['area'] as String;
      String phoneNo = data['phone_no'] as String;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BuyerInformationPage(
          buyerName: buyerName,
          address: address,
          area: area,
          phoneNo: phoneNo,
          productDataId: productDataId,
        ),
      ));
    }
  }
}

class ProductInfoTile extends StatelessWidget {
  final Product product;

  ProductInfoTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          'Product Name:' + product.productName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MFD: ${_formatDate(product.mfd)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Next Service Date: ${_formatDate(product.nextService)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Purchase Date: ${_formatDate(product.purchaseDate)}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }
}
