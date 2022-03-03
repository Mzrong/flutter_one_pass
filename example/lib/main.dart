import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_one_pass/flutter_one_pass.dart' as flutterOnePass;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final TextEditingController textEditingController = TextEditingController();

  String resData = "";

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      flutterOnePass.setup(appId: "your appId", enableCachePhoneNumber: true, timeout: 10.0);
    }

    /// 添加监听
    flutterOnePass.response.listen((response) {
      flutterOnePass.CheckResultResponse res = response as flutterOnePass.CheckResultResponse;
      print(res.errorCode);
      print(res.errorInfo);
      print(res.accesscode);
      print(res.process_id);
      print(res.phone);

      Map<String, dynamic> data = {
        "errorCode": res.accesscode,
        "errorInfo": res.errorInfo,
        "accesscode": res.accesscode,
        "process_id": res.process_id,
        "phone": res.phone
      };

      setState(() {
        resData = data.toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (Platform.isAndroid) {
      flutterOnePass.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterOnePass Example'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: "请填写手机号码",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10
                )
              )
            ),
            ElevatedButton(
              child: Text("初始化(仅限于Android端)"),
              onPressed: () async {
                if (Platform.isIOS) {
                  print(true);
                  return;
                };

                bool status = await flutterOnePass.init(appId: "your appId");
                print(status);
              },
            ),

            ElevatedButton(
              child: Text("获取最近一条缓存的手机号码"),
              onPressed: () async {
                String number = await flutterOnePass.getCachedNumber;
                print(number);
              },
            ),

            ElevatedButton(
              child: Text("获取匹配的手机号码"),
              onPressed: () async {
                if (Platform.isIOS) {
                  List<dynamic> numbers = await flutterOnePass.getIosCachedNumbers;
                  print(numbers);
                  return;
                }
                List<dynamic> numbers = await flutterOnePass.getCachedNumbers(number: "search number");
                print(numbers);
              },
            ),

            ElevatedButton(
              child: Text("销毁所有引用"),
              onPressed: () async {
                bool status = await flutterOnePass.destroy();
              },
            ),

            ElevatedButton(
              child: Text("验证手机号"),
              onPressed: () async {
                String phone = textEditingController.text;
                if (Platform.isAndroid) {
                  /// 验证手机号之前必须先初始化sdk
                  /// flutterOnePass.init()
                  flutterOnePass.checkMobile(phone: phone, cacheNumber: true);
                } else {
                  /// ios端不需要初始化sdk，直接调用 setup 即可
                  flutterOnePass.checkMobile(phone: phone);
                }
              },
            ),

            Container(
              margin: EdgeInsets.only(
                top: 10
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              color: Color(0xfff1f1f1),
              child: SelectableText(
                resData.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff666666)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
