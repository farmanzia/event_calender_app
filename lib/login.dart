import 'package:event_calender_app/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'event_calendar.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController? emailController = TextEditingController();

  TextEditingController? passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var auth = FirebaseAuth.instance;
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

                        print(auth.currentUser!.uid);
                        await auth
                            .signInWithEmailAndPassword(
                                email: "abc@gmail.com", password: "12345678")
                            .then((value) => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => EventCalendarScreen()),
                                (route) => false))
                            .catchError((e) {
                          print("Error Message: $e");
                        });




                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EventCalendarScreen()),
                            (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("email and password required")));
                      }
                    },
                    child: const Text("LogIn")),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => SignUp()));
                    },
                    child: const Text("SignUp Here"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// print(auth.currentUser!.uid);
                  