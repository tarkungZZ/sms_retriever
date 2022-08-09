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
      'deviceID': androidInfo.model,
      'message': message.body
    };
    String jsonBody = json.encode(body);

    //await http.post(Uri.parse('http://139.59.126.33:9999/transaction/sms'),
    await http.post(Uri.parse('http://192.168.0.192:9999/transaction/sms'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
        body: jsonBody);
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
        'deviceID': androidInfo.model,
        'message': message.body
      };
      String jsonBody = json.encode(body);

      //await http.post(Uri.parse('http://139.59.126.33:9999/transaction/sms'),
      await http.post(Uri.parse('http://192.168.0.192:9999/transaction/sms'),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
          body: jsonBody);
    } catch (e) {
      print(e);
    }

    // final response = await http.post(
    //   Uri.parse('http://10.0.0.2:9999/transaction/sms'),
    //   headers: {
    //     "Content-Type": "application/x-www-form-urlencoded",
    //   },
    //   encoding: Encoding.getByName('utf-8'),
    //   body: {message.body},
    // );

    // if (response.statusCode == 200) {
    //   debugPrint('send sms successful.');
    // } else {
    //   debugPrint('send sms failed.');
    // }

    // var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    // var request =
    //     http.Request('POST', Uri.parse('localhost:9999/transaction/sms'));
    // request.bodyFields = message;
    // request.headers.addAll(headers);

    // http.StreamedResponse response = await request.send();

    // if (response.statusCode == 200) {
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }
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
        title: const Text('SMS Retriever.'),
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
