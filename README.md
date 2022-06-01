# flutter_one_pass

[![Pub](https://img.shields.io/pub/v/flutter_one_pass)](https://pub.dartlang.org/packages/flutter_one_pass)

极验OnePass插件

## Getting Started

集成极验OnePass SDK，支持 Android 和 iOS


### 集成

```yaml
dependencies
flutter_one_pass: ^latest version
```

### Android端

无需任何操作

### iOS端

无需任何操作



## 使用文档

### Android

- 导入包

  ```dart
  import 'package:flutter_one_pass/flutter_one_pass.dart' as flutterOnePass;
  ```

- 初始化sdk

  | 参数  | 参数类型 | 必填 | 描述  |
    | ----- | -------- | ---- | ----- |
  | appId | String   | 是   | appId |

  ```dart
  bool status = await flutterOnePass.init(appId: "your appId");
  ```

  注意：务必在页面销毁的时候释放SDK引用

  ```dart
  bool status = await flutterOnePass.destroy();
  ```

- 验证手机号码

  | 参数        | 参数类型 | 必填 | 描述             |
    | ----------- | -------- | ---- | ---------------- |
  | phone       | String   | 是   | 手机号码         |
  | cacheNumber | bool     | 否   | 是否缓存手机号码 |

  ```dart
  flutterOnePass.checkMobile(phone: phone, cacheNumber: true);
  ```

- 监听验证结果

  ```dart
  @override
  void initState() {
    super.initState();
    flutterOnePass.response.listen((reponse) {
      flutterOnePass.CheckResultResponse res = response as flutterOnePass.CheckResultResponse;
    });
  }
  ```

**其他接口**

- 获取最近缓存的一条手机号码

  ```dart
  String number = await flutterOnePass.getCachedNumber;
  ```

- 获取匹配的手机号码

  | 参数   | 参数类型 | 必填 | 描述           |
    | ------ | -------- | ---- | -------------- |
  | number | String   | 是   | 待搜索的字符串 |

  ```dart
  List<dynamic> numbers = await flutterOnePass.getCachedNumbers(number: "search number");
  ```

### iOS

- 导入包

  ```dart
  import 'package:flutter_one_pass/flutter_one_pass.dart' as flutterOnePass;
  ```

- 初始化sdk

  | 参数                   | 参数类型 | 必填 | 默认参数 | 描述                 |
    | ---------------------- | -------- | ---- | -------- | -------------------- |
  | appId                  | String   | 是   | null     | appId                |
  | enableCachePhoneNumber | bool     | 否   | true     | 是否允许缓存手机号码 |
  | timeout                | Double   | 否   | 10.0     | 接口超时             |

   ```dart
  flutterOnePass.setup(appId: "your appId", enableCachePhoneNumber: true, timeout: 10.0);
   ```

- 验证手机号码

  | 参数  | 参数类型 | 必填 | 描述     |
    | ----- | -------- | ---- | -------- |
  | phone | String   | 是   | 手机号码 |

  ```dart
  bool status = flutterOnePass.checkMobile(phone: phone);
  ```

- 监听验证结果

  ```dart
  @override
  void initState() {
    super.initState();
    flutterOnePass.response.listen((reponse) {
      flutterOnePass.CheckResultResponse res = response as flutterOnePass.CheckResultResponse;
    });
  }
  ```

**其他接口**

- 获取最近缓存的一条手机号码

  ```dart
  String number = await flutterOnePass.getCachedNumber;
  ```

- 获取缓存的手机号码列表

  ```dart
  List<dynamic> numbers = await flutterOnePass.getIosCachedNumbers;
  ```

  <u>由于SDK原因，iOS端不支持模糊搜索缓存的手机号码列表</u>



### 验证结果字典

| 参数       | 参数类型 | 描述                                          |
| ---------- | -------- | --------------------------------------------- |
| errorCode  | Int      | 错误码（为0表示验证通过，其他表示验证不通过） |
| errorInfo  | String   | 错误描述                                      |
| processId  | String   | processId                                     |
| accesscode | String   | accesscode                                    |
| phone      | String   | 手机号码                                      |

验证通过之后，需要将`processId`、`accesscode`、`phone`发送到后台进行验证



### 详细文档

[文档地址](https://zrong.life/archives/26.html)

