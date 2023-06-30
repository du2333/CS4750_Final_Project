import 'package:cloudjams/screens/commons/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  final Authentication _authentication = Authentication();
  bool showSignupFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _authentication.currentUser != null
              ? const Text('Profile')
              : Text(showSignupFields ? 'Sign up' : 'Sign in'),
        ),
        body: _authentication.currentUser != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: const Text('How are you doing today?', style: TextStyle(
                        fontSize: 16,
                      ),),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 26),
                      child: Text(_authentication.currentUser!.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                      ),
                      onPressed: () {
                        _authentication.signOut();
                        setState(() {});
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 15),
                          child: TextField(
                            controller: emailController,
                            obscureText: false,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email'),
                          ),
                        ),
                        if (showSignupFields)
                          Container(
                            margin: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 15),
                            child: TextField(
                              controller: usernameController,
                              obscureText: false,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Username'),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 15),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password'),
                          ),
                        ),
                        if (showSignupFields)
                          Container(
                            margin: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 15),
                            child: TextField(
                              controller: confirmController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Confirm password'),
                            ),
                          ),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                              ),
                              onPressed: () {
                                if (!showSignupFields) {
                                  _authentication
                                      .signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text)
                                      .then((value) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Welcome! ${value.user?.displayName}');
                                    Navigator.pop(context);
                                  }).catchError((error) {
                                    Fluttertoast.showToast(
                                        msg: error.toString());
                                  });
                                } else {
                                  if (emailController.text.isEmpty ||
                                      usernameController.text.isEmpty ||
                                      passwordController.text.isEmpty ||
                                      confirmController.text.isEmpty) {
                                    Fluttertoast.showToast(
                                        msg: 'Fields cannot be empty!');
                                    return;
                                  }
                                  if (passwordController.text !=
                                      confirmController.text) {
                                    Fluttertoast.showToast(
                                        msg: "Password doesn't match!");
                                    return;
                                  }
                                  _authentication
                                      .createUserWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text)
                                      .then((userCredential) {
                                    Fluttertoast.showToast(
                                        msg: 'Registered successfully!');
                                    userCredential.user!.updateDisplayName(
                                        usernameController.text);
                                    Navigator.pop(context);
                                  }).catchError((error) {
                                    Fluttertoast.showToast(
                                        msg: error.toString());
                                  });
                                }
                              },
                              child: Text(
                                  showSignupFields ? 'Sign up' : 'Sign in')),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showSignupFields = !showSignupFields;
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            showSignupFields
                                ? 'Already have an account?'
                                : 'No account?',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          )),
                    ),
                  ),
                ],
              ));
  }
}
