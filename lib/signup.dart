import 'package:event_calender_app/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'event_calendar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController? emailController = TextEditingController();

  TextEditingController? passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
   final auth = FirebaseAuth.instance;
  // UserCredential? _userCredential;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                    controller: emailController,
                    validator: ((value) {
                      if (value!.isEmpty && value == "") {
                        return "required";
                      }
                    }),
                    decoration: const InputDecoration(hintText: "Email")),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                    controller: passwordController,
                    validator: ((value) {
                      if (value!.isEmpty && value == "") {
                        return "required";
                      }
                    }),
                    decoration: const InputDecoration(hintText: "Password")),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await auth.createUserWithEmailAndPassword(
                            email: emailController!.text,
                            password: passwordController!.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EventCalendarScreen()));
                      }

                      // await auth
                      //     .createUserWithEmailAndPassword(
                      //         email: emailController!.text,
                      //         password: passwordController!.text)
                      //     .then((value) => Navigator.pushAndRemoveUntil(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (_) => EventCalendarScreen()),
                      //         (route) => false))
                      //     .catchError((e) {
                      //   print("Error Message: $e");
                      // });
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("email and password required")));
                      }
                    },
                    child: const Text("SignUp")),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => LogIn()));
                    },
                    child: const Text("LogIn Here"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
