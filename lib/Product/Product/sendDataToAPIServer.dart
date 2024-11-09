import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateProductScreen(),
    );
  }
}

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> sendData() async {
    String inputText = _controller.text;

    // API URL
    String apiUrl = 'http://192.168.0.183:5050/products';
    // String apiUrl1 = 'http://10.0.2.2:5000/createProduct';

    // Prepare the body (JSON data)
    Map<String, dynamic> body = {
      'text': inputText, // key:value pair as per API requirement
    };

    // Make a POST request
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Successfully sent data
      print("Response: ${response.body}");
    } else {
      // Error occurred
      print("Failed: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Product"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility)),
            ),
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.yellow,
                ),
                Container(
                  height: 100,
                  color: Colors.grey,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    height: 70,
                    width: 100,
                    color: Colors.redAccent,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 70,
                    width: 100,
                    color: Colors.redAccent,
                  ),
                )
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: sendData,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}