import 'dart:convert';
import 'dart:io';

import 'package:cylinder/model/cylinder.dart';
import 'package:cylinder/screens/start.dart';
import 'package:cylinder/tabs/add_cylinder.dart';
import 'package:flutter/material.dart';
import '../widgets/user_section.dart';
import "../tabs/cylinder_info.dart";
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final controller = PageController(
    initialPage: 0,
  );

  double percent = 0.0;

  late Future<List<Cylinder>> futureAlbum;

  final _channel = WebSocketChannel.connect(
    // Uri.parse('wss://echo.websocket.events'),
    Uri.parse('ws://192.168.13.88:5000'),
  );

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    futureAlbum = getCylindersInfo();
    _channel.stream.listen((message) {
      // Handle incoming messages here
      print('Received: $message');
      setState(() {
        percent = double.parse(message);
      });
    });
  }

  //TODO : gracefully handle exceptions in production

  Future<List<Cylinder>> getCylindersInfo() async {
    String? accessToken = await storage.read(key: "access_token");

    debugPrint(' sending token $accessToken');

    final response = await http.get(
      Uri.parse("http://192.168.13.88:5000/api"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List body = jsonDecode(response.body);
      final jsonbody = Cylinder.listFromJson(body);

      return jsonbody;
    } else {
      throw Exception('Failed to load Cylinders');
    }
  }

  Future<void> addCylinder(String tag, String size) async {
    String? accessToken = await storage.read(key: "access_token");
    final response = await http.post(
      Uri.parse("http://192.168.13.88:5000/api"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{'tag': tag, 'size': size}),
    );

    if (response.statusCode == 201) {
      Cylinder newCylinder =
          Cylinder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      print(newCylinder);
    } else {
      throw Exception('Failed to Save cylinder');
    }
  }

  // void _sendMessage() {
  //   _channel.sink.add("hello from flutter");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7ECEF),
      body: SafeArea(
          child: Column(
        children: [
          FutureBuilder<List<Cylinder>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: Column(
                    children: [
                      const UserSection(),
                      Expanded(
                        child: PageView(
                          controller: controller,
                          children: [
                            for (Cylinder cylinder in snapshot.data!)
                              CylinderInfo(
                                  percent: percent, // cylinder.percent,
                                  tag: cylinder.tag,
                                  size: cylinder.size),

                            AddCylinder(
                                createCylinder:
                                    addCylinder) //pass create cylinder function here
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                //i need to set timeout error and display an error
                //if the api did not respond on time
                return Expanded(child: Text('${snapshot.error}'));
              }

              // By default, show a loading spinner.
              return const Expanded(
                  child: StartScreen()); //const CircularProgressIndicator();
            },
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
