import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp10/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int channelIndex;
  const ChatScreen({
    super.key,
    required this.channelIndex,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ServiceNotificationEvent> events = [];
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  late final SharedPreferences prefs;
  var result = "대충 텍스트 슈루룩 화면";

  Future initPrefs() async {
    // prefs = await SharedPreferences.getInstance();
    // final channels = prefs.getStringList('channels');
    // if (channels == null) {
    //   await prefs.setStringList('channels', []);
    // }

    // final whiteList = prefs.getStringList('whiteList');
    // if (whiteList == null) {
    //   await prefs.setStringList('whiteList', []);
    // }
  }

  String convertUint8ListToString(Uint8List uint8list) {
    Uint8List bytes = Uint8List.fromList(uint8list);
    return String.fromCharCodes(bytes);
  }

  void getApiResult() async {
    final channels = prefs.getStringList('channels');
    final idx = channels![widget.channelIndex];
    final chats = prefs.getStringList(idx);
    final res = await ApiService().postChats(chats!);
    print(res);
    getData(res['result']);
    var chatData = prefs.getStringList("data${widget.channelIndex}");
    chatData ??= [];
    chatData.add(res['result']);
    prefs.setStringList("data${widget.channelIndex}", chatData);
    configSceen();
  }

  void setTextData() {
    final channels = prefs.getStringList('channels');
    final idx = channels![widget.channelIndex];
    final channel = prefs.getStringList(idx);
    print(channel);
    result = '';
    for (var t in channel!) {
      result += '$t\n';
    }
    getData(result);
  }

  // void saveEvent(ServiceNotificationEvent event) async {
  //   prefs = await SharedPreferences.getInstance();
  //   final channels = prefs.getStringList('channels');
  //   if (event.largeIcon != null) {
  //     final icon = convertUint8ListToString(event.largeIcon!);
  //     List<String>? channel = prefs.getStringList(icon);
  //     if (channel != null) {
  //       print("존재하는 채팅방");
  //       channel.add({event.title, event.content}.toString());
  //       prefs.setStringList(icon, channel);
  //     } else {
  //       print("없는 채팅방");
  //
  //       // 새로운 채팅방 추가
  //       final channels = prefs.getStringList('channels');
  //       channels!.add(icon);
  //       prefs.setStringList('channels', channels);
  //       prefs.setStringList(icon, [event.content!]);
  //
  //       // whitelist 추가
  //       final whiteList = prefs.getStringList('whiteList');
  //       whiteList!.add("false");
  //     }
  //   }
  //   print("현재 저장된 채팅방 갯수: ${channels?.length}");
  // }

  void configSceen() async {
    prefs = await SharedPreferences.getInstance();
    final chatData = prefs.getStringList("data${widget.channelIndex}");
    if (chatData != null) {
      for (var data in chatData) {
        result += '$data\n----------';
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // initPrefs();
    configSceen();
    // _subscription =
    //     NotificationListenerService.notificationsStream.listen((event) {
    //   saveEvent(event);
    //   setState(() {
    //     events.add(event);
    //     print(event);
    //   });
    // });
  }

  getData(String data) {
    setState(() {
      result = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat zip 채팅방 ${widget.channelIndex + 1}'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 500,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(result),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: TextButton(
                onPressed: getApiResult,
                child: const Text("딸깍"),
              ),
            ),
            TextButton(
              onPressed: () {
                setTextData();
                // String result = '채팅방 갯수: ';
                // final channels = prefs.getStringList('channels');
                // result += '${channels!.length}';
                // for (var k in channels) {
                //   final channel = prefs.getStringList(k);
                //   for (var i in channel!) {
                //     result += i;
                //   }
                //   result += '\n\n\n';
                // }
                // getData(result);
              },
              child: const Text("채팅 기록 불러오기 딸깍"),
            ),
          ],
        ),
      ),
    );
  }
}
