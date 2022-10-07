import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

onBackgroundMessage(SmsMessage message) async {
  debugPrint("onBackgroundMessage called");
  debugPrint(message.body);

  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    debugPrint('Running on ${androidInfo.model}');

    Map<String, dynamic> body = {
      'bid': '3',
      'deviceID': androidInfo.model,
      'address': message.address,
      'message': message.body,
      'date': message.date,
    };
    String jsonBody = json.encode(body);

    var array = ['http://192.168.68.198:9999/sms/sms'];

    for (var i = 0; i < array.length; i++) {
      await http.post(Uri.parse(array[i]),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
          body: jsonBody);
    }
  } catch (e) {
    print(e);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });

    debugPrint(message.body);

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.model}');

      Map<String, dynamic> body = {
        'bid': '3',
        'deviceID': androidInfo.model,
        'address': message.address,
        'message': message.body,
        'date': message.date,
      };
      String jsonBody = json.encode(body);

      var array = ['http://192.168.68.198:9999/sms/sms'];

      for (var i = 0; i < array.length; i++) {
        await http.post(Uri.parse(array[i]),
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName('utf-8'),
            body: jsonBody);
      }
    } catch (e) {
      print(e);
    }
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('SBO 03'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Latest received SMS : $_message")),
        ],
      ),
    ));
  }
}
