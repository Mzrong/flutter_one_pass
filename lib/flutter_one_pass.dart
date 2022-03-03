import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// flutter_one_pass
/// author: zrong
/// email: zengrong27@gmail.com
/// https://zrong.life

MethodChannel _channel = MethodChannel('life.zrong/flutter_one_pass')
  ..setMethodCallHandler(_handler);

StreamController _responseController = new StreamController.broadcast();

Stream get response => _responseController.stream;

/// 配置参数 仅在ios端设置，Android端直接调用 init 方法
/// [appId] appid
/// [enableCachePhoneNumber] 是否缓存手机号码
/// [timeout] 请求超时
Future<bool> setup(
    {required String appId,
    bool enableCachePhoneNumber = true,
    double timeout = 10.0}) async {
  if (Platform.isAndroid) return true;
  bool setupStatus = await _channel.invokeMethod("setup", {
    "appId": appId,
    "enableCachePhoneNumber": enableCachePhoneNumber,
    "timeout": timeout
  });
  return setupStatus;
}

/// 初始化sdk 仅在Android端配置，ios端直接调用 setup 方法
/// [appId] appId
Future<bool> init({required String appId}) async {
  if (Platform.isAndroid) {
    bool isInit = await _channel.invokeMethod("init", {"appId": appId});
    return isInit;
  }
  return true;
}

/// 获取本地最近一条缓存的手机号
Future<String> get getCachedNumber async {
  String number = await _channel.invokeMethod("getCachedNumber");
  return number;
}

/// 获取匹配的手机号列表
/// [number] 匹配的手机号码字符串 eg: 888, 133, 3898
Future<List<dynamic>> getCachedNumbers({required String number}) async {
  List<dynamic> numbers =
      await _channel.invokeMethod("getCachedNumbers", {"number": number});
  return numbers;
}

/// 获取匹配的手机号列表ios端
/// 由于sdk限制，无法模糊查询手机号码
Future<List<dynamic>> get getIosCachedNumbers async {
  List<dynamic> numbers = await _channel.invokeMethod("getCachedNumbers");
  return numbers;
}

/// 验证手机号
/// [phone]待验证的手机号
/// [cacheNumber]是否缓存手机号 该参数在ios端无效
checkMobile({required String phone, bool cacheNumber = true}) async {
  await _channel.invokeMethod(
      "checkMobile", {"phone": phone, "cacheNumber": cacheNumber});
}

/// 释放引用
/// 仅在Android端有效
Future<bool> destroy() async {
  if (Platform.isAndroid) {
    bool isDestroy = await _channel.invokeMethod("destroy");
    return isDestroy;
  } else {
    return true;
  }
}

/// 添加监听
/// [methodCall]
/// 本机号码验证结果返回
Future<dynamic> _handler(MethodCall methodCall) {
  if (methodCall.method == "onCheckResponse") {
    _responseController.add(CheckResultResponse.fromJson(
        Map<String, dynamic>.from(methodCall.arguments)));
  }
  return Future.value(true);
}

class CheckResultResponse {
  final int errorCode;
  final String processId;
  final String accesscode;
  final String phone;
  final String errorInfo;

  CheckResultResponse(
      {this.errorCode = 0,
      this.processId = "",
      this.accesscode = "",
      this.phone = "",
      this.errorInfo = ""});

  factory CheckResultResponse.fromJson(Map<String, dynamic> json) {
    return CheckResultResponse(
        errorCode: int.parse("${json['error_code']}"),
        processId: json['process_id'],
        accesscode: json['accesscode'],
        phone: json['phone'],
        errorInfo: json['error_info']);
  }
}
