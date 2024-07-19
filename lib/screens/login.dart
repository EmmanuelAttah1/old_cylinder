import 'dart:convert';

import 'package:cylinder/screens/first.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Create storage
  final storage = new FlutterSecureStorage();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showError = false;

  Future<void> loginUser() async {
    String username = usernameController.value.text;
    String password = passwordController.value.text;

    final response = await http.post(
      Uri.parse("http://192.168.13.88:5000/user/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Write value
      await storage.write(key: "access_token", value: jsonDecode(response.body)['access_token']);

      // Read value
      String? token = await storage.read(key: "access_token");

      debugPrint("my token is $token");


      //redirect to a different page
      goToMainApp();
    } else {
      setState(() {
        showError = true;
      });
      throw Exception('Invalid Username or password');
    }
  }

  void goToMainApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showError) const Text("Invalid Username or password"),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your Password',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: loginUser,
              child: const Text("Login"),
            ),
            ElevatedButton(onPressed: (){}, child: const Text("Sign up with google"))
          ],
        ),
      ),
    );
  }
}
