package life.zrong.flutter_one_pass

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.geetest.onepassv2.OnePassHelper
import com.geetest.onepassv2.listener.OnePassListener

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import kotlin.collections.HashMap

/**
 * FlutterOnePassPlugin
 * @author zrong
 * @email zengrong27@gmail.com
 * @website https://zrong.life
 */
class FlutterOnePassPlugin: FlutterPlugin, MethodCallHandler {

  private var tag: String = "| zrong.life | flutter_one_pass |"

  private var channelName: String = "life.zrong/flutter_one_pass"

  private lateinit var onePassListener: OnePassListener

  private lateinit var channel : MethodChannel

  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      Extras.FOR_FLUTTER_METHOD_INIT -> init(call, result)
      Extras.FOR_FLUTTER_METHOD_GET_CACHED_NUMBER -> getCachedNumber(call, result)
      Extras.FOR_FLUTTER_METHOD_GET_CACHED_NUMBERS -> getCachedNumbers(call, result)
      Extras.FOR_FLUTTER_METHOD_DESTROY -> destroy(call, result)
      Extras.FOR_CHECK_MOBILE -> checkMobile(call, result)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /**
   * 初始化OnePass
   */
  private fun init(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      val map: HashMap<String, Any> = call.arguments<HashMap<String, Any>>()

      if (!map.containsKey("appId")) {
        throw Exception("[appId]不能为空")
      }

      if ("${map["appId"]}".isEmpty()) {
        throw Exception("[appId]不能为空")
      }

      OnePassHelper.with().init(context, "${map["appId"]}", 8000)
      registerListener()
      Log.i(tag, "初始化成功")
      result.success(true)
    } catch (e: Exception) {
      result.success(false)
      Log.i(tag, "${e.message}")
    }
  }

  /**
   * 获取本地最近一条缓存的手机号
   */
  private fun getCachedNumber(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      val number: String = OnePassHelper.with().cachedNumber
      Log.i(tag, "获取成功")

      result.success(number)
    } catch (e: Exception) {
      result.success("")
      Log.i(tag, "${e.message}")
    }
  }

  /**
   * 获取匹配的手机号码列表
   */
  private fun getCachedNumbers(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      val map: HashMap<String, Any> = call.arguments<HashMap<String, Any>>()

      if (!map.containsKey("number")) {
        throw Exception("手机号码不能为空")
      }

      if ("${map["number"]}".isEmpty()) {
        throw Exception("手机号码不能为空")
      }

      val numbers: List<String> = OnePassHelper.with().getCachedNumbers("${map["number"]}")
      Log.i(tag, "匹配完成")

      result.success(numbers)
    } catch (e: Exception) {
      Log.i(tag, "${e.message}")
    }
  }

  /**
   * 释放SDK引用
   */
  private fun destroy(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      OnePassHelper.with().cancel()
      result.success(true)
      Log.i(tag, "释放成功")
    } catch (e: Exception) {
      result.success(false)
      Log.i(tag, "${e.message}")
    }
  }

  /**
   * 添加监听
   */
  private fun registerListener() {
    onePassListener = object: OnePassListener() {
      override fun onTokenFail(jsonObject: JSONObject) {
        Log.i(tag, "本机认证失败")

        val resMap: HashMap<String, Any> = HashMap()
        resMap["error_code"] = jsonObject.get("code")
        resMap["process_id"] = ""
        resMap["accesscode"] = ""
        resMap["phone"] = ""
        resMap["error_info"] = (jsonObject.get("metadata") as JSONObject).get("error_data")

        channel.invokeMethod("onCheckResponse", resMap)
      }

      override fun onTokenSuccess(jsonObject: JSONObject) {
        try {
          Log.i(tag, "onTokenSuccess: $jsonObject")

          val resMap: HashMap<String, Any> = HashMap()
          resMap["error_code"] = 0
          resMap["process_id"] = jsonObject.get("process_id")
          resMap["accesscode"] = jsonObject.get("accesscode")
          resMap["phone"] = jsonObject.get("phone")
          resMap["error_info"] = "ok"

          channel.invokeMethod("onCheckResponse", resMap)
        } catch (e: Exception) {
          Log.i(tag, "发生错误${e.message}")
        }
      }

    }
  }

  /**
   * 校验本机号码
   */
  private fun checkMobile(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      val map: HashMap<String, Any> = call.arguments<HashMap<String, Any>>()

      if (!map.containsKey("phone")) {
        throw Exception("手机号码不能为空")
      }

      if ("${map["phone"]}".isEmpty()) {
        throw Exception("手机号码不能为空")
      }

      OnePassHelper.with().setCacheNumberEnable(map["cacheNumber"] as Boolean)
      OnePassHelper.with().getToken("${map["phone"]}", onePassListener)
    } catch (e: Exception) {
      Log.i(tag, "${e.message}")
    }
  }
}
