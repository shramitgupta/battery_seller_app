import 'dart:developer';
import 'package:battery_service_app/Auth/Admin_auth/adminlogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeRegister extends StatefulWidget {
  const EmployeeRegister({Key? key}) : super(key: key);

  @override
  _EmployeeRegisterState createState() => _EmployeeRegisterState();
}

class _EmployeeRegisterState extends State<EmployeeRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isSigningUp = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isSigningUp = true;
        });

        final authResult =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final user = authResult.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('Employee')
              .doc(user.uid)
              .set({
            'email': user.email,
            'name': nameController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful!'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      } catch (error) {
        log(error.toString());
        if (error is FirebaseAuthException) {
          if (error.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Email is already in use. Please use a different email.'),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sign up failed'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        setState(() {
          isSigningUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Employee Sign Up",
          style: TextStyle(
              color: Colors.white, fontSize: 30 * widthRatio * heightRatio),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                      "Name",
                      style: TextStyle(
                        fontSize: 18 * widthRatio * heightRatio,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10 * heightRatio,
                    ),
                    TextFormField(
                      controller: nameController,
                      validator: _validateName,
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
                      "E-Mail",
                      style: TextStyle(
                        fontSize: 18 * widthRatio * heightRatio,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10 * heightRatio,
                    ),
                    TextFormField(
                      controller: emailController,
                      validator: _validateEmail,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10 * heightRatio,
                    ),
                    TextFormField(
                      controller: passwordController,
                      validator: _validatePassword,
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
                        onPressed: isSigningUp ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0 * widthRatio,
                              vertical: 7.0 * heightRatio),
                          backgroundColor: Colors.red[300],
                          shape: const StadiumBorder(),
                        ),
                        child: isSigningUp
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 20 * heightRatio * widthRatio,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
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
