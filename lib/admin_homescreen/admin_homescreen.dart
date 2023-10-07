import 'package:battery_service_app/Auth/Admin_auth/adminlogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void logOut() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Log Out"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const AdminLogin()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    final double fontSize = 14.0 * heightRatio * widthRatio;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.red[300],
        backgroundColor: Colors.white, // Button text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 36.0 * MediaQuery.of(context).textScaleFactor,
            color: Colors.red[300], // Icon color
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, color: Colors.white), // Change icon color
        ),
        title: Text(
          "Manager",
          style: TextStyle(
            fontSize: 26 * widthRatio * heightRatio,
            color: Colors.white, // Change title text color
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logOut,
            icon: Icon(
              Icons.logout,
              size: 32 * widthRatio * heightRatio,
              color: Colors.white, // Change icon color
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16.0, // Add spacing between buttons
          crossAxisSpacing: 16.0, // Add spacing between buttons
          children: [
            buildGridButton(
              icon: Icons.shopping_cart,
              label: "Sales Form",
              onPressed: () {
                // Add your action for button 1
              },
            ),
            buildGridButton(
              icon: Icons.access_time,
              label: "Today's Work",
              onPressed: () {
                // Add your action for button 2
              },
            ),
            buildGridButton(
              icon: Icons.location_on,
              label: "Tracking",
              onPressed: () {
                // Add your action for button 3
              },
            ),
            buildGridButton(
              icon: Icons.pie_chart,
              label: "Sales Data",
              onPressed: () {
                // Add your action for button 4
              },
            ),
            buildGridButton(
              icon: Icons.monetization_on,
              label: "Earnings",
              onPressed: () {
                // Add your action for button 5
              },
            ),
            buildGridButton(
              icon: Icons.people,
              label: "Employee Performance",
              onPressed: () {
                // Add your action for button 6
              },
            ),
            buildGridButton(
              icon: Icons.person_add,
              label: "Employee Registration",
              onPressed: () {
                // Add your action for button 7
              },
            ),
            buildGridButton(
              icon: Icons.delete_forever,
              label: "Delete Customer",
              onPressed: () {
                // Add your action for button 8
              },
            ),
            buildGridButton(
              icon: Icons.person_remove,
              label: "Delete Employee",
              onPressed: () {
                // Add your action for button 9
              },
            ),
          ],
        ),
      ),
    );
  }
}
