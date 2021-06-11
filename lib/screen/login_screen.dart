import 'package:f_ws_twoway/screen/chat_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  void goToMainPage(String nickname, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChatScreen(nickname)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Login Page")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Nickname"),
              onSubmitted: (nickname) => goToMainPage(nickname, context),
            ),
          ),
          FlatButton(
              onPressed: () => goToMainPage(controller.text, context),
              child: Text("Log In"))
        ],
      ));
}
