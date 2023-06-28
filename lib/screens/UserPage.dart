import 'package:cloudjams/screens/commons/Authentication.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Authentication _authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userNameController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Password'),
              ),
              ElevatedButton(
                  onPressed: () {
                    _authentication
                        .signInWithEmailAndPassword(
                            email: userNameController.text,
                            password: passwordController.text)
                        .then((value) {
                      print('===============Signed in================');
                    }).catchError((error) {
                      print('=======Failed=========');
                      print(error.toString());
                    });
                  },
                  child: const Text('Sign in')),
              ElevatedButton(
                  onPressed: () {
                    _authentication
                        .createUserWithEmailAndPassword(
                            email: userNameController.text,
                            password: passwordController.text)
                        .then((value) {
                      print('========Success!==========');
                    }).catchError((error) {
                      print('========Fail=============');
                      print(error.toString());
                    });
                  },
                  child: const Text('Sign up')),
              ElevatedButton(
                  onPressed: () {
                    _authentication.signOut().then((value) {
                      print('========Success Signed out!==========');
                    }).catchError((error) {
                      print('========Fail=============');
                      print(error.toString());
                    });
                  },
                  child: const Text('Sign out')),
              StreamBuilder(
                  stream: _authentication.userStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return const Text('User logged in');
                    } else {
                      return const Text('User Not logged in');
                    }
                  }),
            ],
          ),
        ));
  }
}
