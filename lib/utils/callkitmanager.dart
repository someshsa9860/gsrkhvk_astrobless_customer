import 'package:flutter/services.dart';

class CallKitManager {
  static const MethodChannel _channel =
      MethodChannel('com.gsc.qb.austro.user/channel_test');

  static Future<List<dynamic>> getActiveCalls() async {
    print("start getting getActiveCalls");

    try {
      final List<dynamic> result = await _channel.invokeMethod('activeCalls');
      return result;
    } catch (e,s) {
              print(s);
      print("Failed to get active calls: $e");
      return [];
    }
  }
}
