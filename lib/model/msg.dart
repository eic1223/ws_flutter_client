import 'package:flutter/foundation.dart';

class Msg {
  String sender;
  String target;
  String command;
  String value;

  Msg({this.sender, this.target, this.command, this.value});

  factory Msg.fromJson(Map<String, dynamic> json) {
    return Msg(
      sender: json['sender'],
      target: json['target'],
      command: json['command'] ?? "",
      value: json['value'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'target': target,
        'command': command,
        'value': value,
      };
}
