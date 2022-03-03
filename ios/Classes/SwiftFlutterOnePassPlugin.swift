import Flutter
import UIKit
import OneLoginSDK

/**
 * flutter_one_pass
 * @author zrong
 * @email zengrong27@gmail.com
 */

public class SwiftFlutterOnePassPlugin: NSObject, FlutterPlugin, GOPManagerDelegate {
    
    /**
     native channelName
     */
    private static var channelName = "life.zrong/flutter_one_pass"
    
    /**
     FlutterMethodChannel
     */
    private static var channel: FlutterMethodChannel?
    
    /**
     appid
     */
    var appId: String = ""
    
    /**
     是否缓存手机号码
     */
    var enableCachePhoneNumber: Bool = true
    
    /**
     接口超时
     */
    var timeout: Double = 10.0

    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let _channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    SwiftFlutterOnePassPlugin.channel = _channel
    let instance = SwiftFlutterOnePassPlugin()
    registrar.addMethodCallDelegate(instance, channel: _channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    
    switch method {
    case "setup":
        self.setup(call: call, result: result)
        break
    case "checkMobile":
        self.checkMobile(call: call, result: result)
        break;
    case "getCachedNumber":
        self.getCachedNumber(call: call, result: result)
        break
    case "getCachedNumbers":
        self.getCachedNumbers(call: call, result: result)
        break
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    public func gtOnePass(_ manager: GOPManager, errorHandler error: GOPError) {
        let resData = [
            "error_code": error.code,
            "process_id": "",
            "accesscode": "",
            "phone": "",
            "error_info": error.description
        ] as [String : Any]
        SwiftFlutterOnePassPlugin.channel!.invokeMethod("onCheckResponse", arguments: resData)
    }
    
    public func gtOnePass(_ manager: GOPManager, didReceiveDataToVerify data: [AnyHashable : Any]) {
        let resData = [
            "error_code": 0,
            "process_id": data["process_id"],
            "accesscode": data["accesscode"],
            "phone": data["phone"],
            "error_info": "ok"
        ]
        SwiftFlutterOnePassPlugin.channel!.invokeMethod("onCheckResponse", arguments: resData)
    }
    
    /**
     调用此方法来初始化插件
     */
    private func setup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let _appId = CommonUtils.getParam(call: call, result: result, param: "appId") as! String
        let _enableCachePhoneNumber = CommonUtils.getParam(call: call, result: result, param: "enableCachePhoneNumber") as! Bool
        let _timeout = CommonUtils.getParam(call: call, result: result, param: "timeout") as! Double
        
        self.appId = _appId
        self.enableCachePhoneNumber = _enableCachePhoneNumber
        self.timeout = _timeout
        result(true)
    }
    
    /**
     懒加载方式初始化sdk
     */
    private lazy var gopManager: GOPManager = {
        GOPManager.setCachePhoneEnabled(self.enableCachePhoneNumber)
        let manager = GOPManager.init(customID: self.appId, timeout: self.timeout)
        manager.delegate = self as GOPManagerDelegate
        return manager
    }()
    

    /**
     获取最后一条缓存的手机号码
     */
    private func getCachedNumber(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let phone = GOPManager.getCachedPhone(), phone.count > 0 {
            result(phone)
        } else {
            result("")
        }
    }
    
    /**
     获取缓存在本地的手机号码列表
     */
    private func getCachedNumbers(call: FlutterMethodCall, result: @escaping FlutterResult) {
        GOPManager.getCachedPhones { (phones) in
            if phones.count > 0 {
                result(phones)
            } else {
                result([String]())
            }
        }
    }
    
    /**
     校验手机号码
     */
    private func checkMobile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var phone = CommonUtils.getParam(call: call, result: result, param: "phone") as! String
        phone = phone.replacingOccurrences(of: " ", with: "")
        
        if (phone.isEmpty || phone.count < 11) {
            result(false)
        } else {
            self.gopManager.verifyPhoneNumber(phone)
        }
        
    }
    
}
