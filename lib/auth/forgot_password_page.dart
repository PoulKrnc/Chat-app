// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:pavli_text/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  //
  // this widget resets password of entered email
  // it sends email for reseting password
  // widgets:
  // - text form field "Email"
  // - button: Reset Password
  //

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
            padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20),
                // ignore: prefer_const_literals_to_create_immutables
                boxShadow: [
                  const BoxShadow(
                      offset: Offset(5, 5), blurRadius: 10, color: Colors.grey)
                ]),
            child: TextFormField(
              controller: emailController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  border: InputBorder.none,
                  hintText: "Email"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? "Enter a valid email"
                      : null,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: GestureDetector(
              onTap: resetPassword,
              child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        const BoxShadow(
                            offset: Offset(5, 5),
                            blurRadius: 10,
                            color: Colors.grey)
                      ]),
                  child: const Center(
                    child: Row(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Spacer(),
                        Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        ),
                        Text(
                          " Reset Password",
                          // ignore: deprecated_member_use
                          textScaleFactor: 1.4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        Spacer(),
                      ],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }

  // this function sends entered email a reset password email.
  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      Utils.showSnackBar("Password Reset Email Sent.");
      Navigator.of(context).popUntil((route) => route.isFirst);
      // ignore: unused_catch_clause
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar("Something went wrong.");
      Navigator.of(context).pop();
    }
  }
}
