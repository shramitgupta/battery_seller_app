import 'package:battery_service_app/Auth/Admin_auth/admin_signup.dart';
import 'package:battery_service_app/Auth/employee_auth/employee_login.dart';
import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double heightRatio = size.height / 915;
    final double widthRatio = size.width / 412;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100 * heightRatio,
            ),
            Text(
              'Admin Login',
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .redAccent, // Change the border color to pink when focused
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .redAccent, // Change the border color to pink when focused
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .redAccent, // Change the border color to pink when focused
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .redAccent, // Change the border color to pink when focused
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0 * widthRatio,
                            vertical: 7.0 * heightRatio),
                        backgroundColor: Colors.red[300],
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
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
                        "Or ",
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
                                builder: (context) => const AdminSignUp()),
                          );
                        },
                        child: Text(
                          'Create a new account',
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
                                builder: (context) => const EmployeeLogin()),
                          );
                        },
                        child: Text(
                          'Employee',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
