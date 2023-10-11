import 'package:flutter/material.dart';

class AdminTodaysWorks extends StatefulWidget {
  const AdminTodaysWorks({super.key});

  @override
  State<AdminTodaysWorks> createState() => _AdminTodaysWorksState();
}

class _AdminTodaysWorksState extends State<AdminTodaysWorks> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todays Works",
          style: TextStyle(
              color: Colors.white, fontSize: 30 * widthRatio * heightRatio),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
    );
  }
}
