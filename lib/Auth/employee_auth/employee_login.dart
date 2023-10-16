import 'dart:developer';
import 'package:battery_service_app/Auth/Admin_auth/adminlogin.dart';
import 'package:battery_service_app/employee_homescreen/employee_homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeLogin extends StatefulWidget {
  const EmployeeLogin({super.key});

  @override
  State<EmployeeLogin> createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorText = '';
  bool isLoading = false;

  Future<bool> verifyDealerEmail(String enteredEmail) async {
    try {
      final dealerSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .where('email', isEqualTo: enteredEmail)
          .get();
      return dealerSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void login() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorText = 'Please fill in all fields.';
      });
      return;
    }

    bool isDealerEmail = await verifyDealerEmail(email);
    if (!isDealerEmail) {
      setState(() {
        isLoading = false;
        errorText = 'User not found.';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const EmployeeHomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (ex) {
      setState(() {
        isLoading = false;
        if (ex.code == 'user-not-found') {
          errorText = 'User not found.';
        } else if (ex.code == 'wrong-password') {
          errorText = 'Wrong password.';
        } else {
          errorText = 'An error occurred';
          log(ex.message.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100 * heightRatio,
              ),
              Text(
                'Employee Login',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40 * heightRatio * widthRatio,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
              SizedBox(
                height: 50 * heightRatio,
              ),
              Image.asset(
                'images/logo.png',
                height: 100 * heightRatio,
                width: 100 * widthRatio,
              ),
              SizedBox(
                height: 30 * heightRatio,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "E-Mail",
                      style: TextStyle(
                          fontSize: 18 * widthRatio * heightRatio,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10 * heightRatio,
                    ),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30 * heightRatio,
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                          fontSize: 18 * widthRatio * heightRatio,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10 * heightRatio,
                    ),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50 * heightRatio,
                    ),
                    SizedBox(
                      height: 50 * heightRatio,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0 * widthRatio,
                              vertical: 7.0 * heightRatio),
                          backgroundColor: Colors.red[300],
                          shape: const StadiumBorder(),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 20 * heightRatio * widthRatio,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 20 * heightRatio,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Login As ",
                          style: TextStyle(
                            color: const Color(0xFF6B6B6B),
                            fontSize: 16 * widthRatio * heightRatio,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminLogin()),
                            );
                          },
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16 * widthRatio * heightRatio,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20 * heightRatio,
                    ),
                    if (errorText.isNotEmpty)
                      Text(
                        errorText,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16 * widthRatio * heightRatio,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
