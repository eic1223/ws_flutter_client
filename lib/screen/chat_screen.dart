import 'dart:convert';

import 'package:f_ws_twoway/model/msg.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const YOUR_SERVER_IP = '10.0.2.2';
const YOUR_SERVER_PORT = '3000';
const URL = 'ws://$YOUR_SERVER_IP:$YOUR_SERVER_PORT';

class ChatScreen extends StatefulWidget {
  ChatScreen(this.nickname);

  final String nickname;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(URL));

  bool isMatchStarted = false;

  //bool isMyTurn = false;
  int whoIsAnswering = 0; // 0="none", 1="my turn", 2="opponent' turn"

  bool isBuzzerClickChangeFinished = false;

  //List<String> messageList = [];

  @override
  void initState() {
    //channel = WebSocketChannel.connect(Uri.parse(URL+'/${widget.nickname}'));
    isMatchStarted = false;
    super.initState();
    print(widget.nickname);
  }

  @override
  void dispose() {
    channel.sink.close();
    // setState(() {
    //   messageList = [];
    // });
    print('disposed!');
    super.dispose();
  }

  // setState()를 하면 다시 Build 되기 때문에 무한 호출되는 문제가 생김.
  // 그래서 isBuzzerClickChangeFinished 를 추가함.
  void changeButtonLayout(int whoIsAnsweringVal) async {
    print("changeButtonLayout() started");
    await Future.delayed(Duration(milliseconds: 10));
    if (!isBuzzerClickChangeFinished) {
      setState(() {
        whoIsAnswering = whoIsAnsweringVal;
      });
    }
    isBuzzerClickChangeFinished = true;
    print("changeButtonLayout() finished");
  }

  // 서버가 보낸 메세지의 값에 따라 다음 행동 실행하는 로직
  onGetMessage(Msg msg){
    if (msg.sender == 'server') {

      if (msg.command == 'YOUR_TURN') {
        // 내 턴인 상태 (정답 입력 가능)
        changeButtonLayout(1);
        print('now My turn!');
      } else if (msg.command == 'OPPONENT_TURN') {
        // 상대방 턴인 상태 (정답 입력 불가능)
        changeButtonLayout(2);
        print('now OPPONENT turn!');
      } else if (msg.command == 'NONE_TURN') {
        // 누구의 턴도 아닌 상태 (부저를 누를 수 있는 상태)
        changeButtonLayout(0);
        print("now no one's turn!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen(${widget.nickname})"),
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                var savedSnapshot = snapshot;
                if (savedSnapshot.data != null) {
                  print('savedSnapshot.data: ${savedSnapshot.data.toString()}');
                  Msg receivedMsg =
                      Msg.fromJson(json.decode(savedSnapshot.data));
                  print(
                      'receivedMsg: ${receivedMsg.sender}/${receivedMsg.target}/${receivedMsg.command}/${receivedMsg.value}');

                  onGetMessage(receivedMsg);
                }

                return savedSnapshot.hasData
                    ? Text(savedSnapshot.data.toString(),
                        style: TextStyle(fontSize: 22))
                    : CircularProgressIndicator();
              },
            ),
            Divider(),
            (!isMatchStarted)
                ? GestureDetector(
                    onTap: () {
                      clickBtn("MATCH_START");
                      setState(() {
                        isMatchStarted = true;
                      });
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          '매치 시작',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  )
                : (whoIsAnswering == 0)
                    ? GestureDetector(
                        onTap: () {
                          clickBtn("BUZZER");
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              '정답',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      )
                    : (whoIsAnswering == 1)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [btn("1"), btn("2"), btn("3"), btn("4")],
                          )
                        : Container(
                            width: 200,
                            height: 80,
                            color: Colors.orange,
                            child: Center(child: Text("상대방 입력 중...")),
                          ),
          ],
        ),
      ),
    );
  }

  clickBtn(String value) {
    channel.sink.add('{"sender": "${widget.nickname}", "value": "$value"}');
    print('click btn: $value');
  }

  Widget btn(String btnVal) {
    return GestureDetector(
      onTap: () {
        clickBtn(btnVal);
      },
      child: Container(
        width: 60,
        height: 60,
        color: Colors.pinkAccent,
        child: Center(
          child: Text(
            btnVal,
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

/* ListView getMessageList() {
    List<Widget> listWidget = [];

    for (String message in messageList) {
      listWidget.add(ListTile(
        title: Container(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message),
          ),
        ),
      ));
    }

    return ListView(children: listWidget,);
  }*/
}
