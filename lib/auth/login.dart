// ignore_for_file: sort_child_properties_last

import 'package:pavli_text/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_password_page.dart';

class LogInPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LogInPage({super.key, required this.showRegisterPage});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  //
  // widget called from _auth.dart_
  // responsibile for showing widgets required for login
  // widgets:
  // - text: "Log In"
  // - text form field: "Email"
  // - text form field: "Password"
  // - button: "Sign Up":
  //   - _VoidCallback showLogInPage_
  // - button: "Log In"
  //   - calls logIn function
  //

  // text controlers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = true;
  final formKey = GlobalKey<FormState>();

  // checks email and password entered and does its thing
  Future logIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      printY(e.code);
      if (e.code == 'user-not-found') {
        Utils.showSnackBar('Provided email does not exist in our database.');
      } else if (e.code == 'wrong-password') {
        Utils.showSnackBar('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        Utils.showSnackBar('Provided email is invalid.');
      } else {
        Utils.showSnackBar('Something went wrong.');
        //log(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 33,
                        color: Colors.blue),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: InputBorder.none,
                          hintText: "Email"),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                          iconColor: Colors.black,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: Icon(_passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          hintText: "Password"),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        )),
                      ),
                      const Spacer()
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: logIn,
                          child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20),
                                  // ignore: prefer_const_literals_to_create_immutables
                                  boxShadow: [
                                    const BoxShadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 5,
                                        color: Colors.grey)
                                  ]),
                              child: Center(
                                child: Text(
                                  "Log In",
                                  // ignore: deprecated_member_use

                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: widget.showRegisterPage,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
