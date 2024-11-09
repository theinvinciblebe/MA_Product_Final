import 'package:flutter/material.dart';

void main() {
  runApp(FormSubmit());
}

class FormSubmit extends StatefulWidget {
  const FormSubmit({super.key});

  @override
  State<FormSubmit> createState() => _FormSubmitState();
}

class _FormSubmitState extends State<FormSubmit> {
  final _userForm = TextEditingController();
  String name = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.person),
          title: Text("Create New User"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                    child: Center(
                      child: Text(
                        "${name}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 50),
                      ),
                    )),
              ),
              TextField(
                controller: _userForm,
                decoration: InputDecoration(
                    hintText: "Enter user name: ",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _userForm.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    name = _userForm.text;
                  });
                },
                child: Text("Post"),
              )
            ],
          ),
        ),
      ),
    );
  }
}