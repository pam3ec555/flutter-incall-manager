import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';

enum MediaType { AUDIO, VIDEO }

enum ForceSpeakerType { DEFAULT, FORCE_ON, FORCE_OFF }

enum RingtoneUriType { DEFAULT, BUNDLE }

class IncallManager {
  final MethodChannel _channel =
      const MethodChannel('FlutterInCallManager.Method');
  final EventChannel _eventChannel = EventChannel('FlutterInCallManager.Event');

  IncallManager() {
    _eventChannel.receiveBroadcastStream().listen(eventListener,
        onError: (Object obj) => throw obj as PlatformException);
  }

  /// Start InCallManager
  Future<void> start(
      {bool auto = true,
      MediaType media = MediaType.AUDIO,
      String? ringback}) async {
    await _channel.invokeMethod('start', <String, dynamic>{
      'media': media == MediaType.AUDIO ? 'audio' : 'video',
      'auto': auto,
      'ringback': ringback
    });
  }

  /// Stop InCallManager
  Future<void> stop({String? busytone}) async {
    await _channel
        .invokeMethod('stop', <String, dynamic>{'busytone': busytone});
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    await _channel
        .invokeMethod('setKeepScreenOn', <String, dynamic>{'enabled': enabled});
  }

  Future<void> setSpeakerphoneOn(bool enabled) async {
    await _channel.invokeMethod(
        'setSpeakerphoneOn', <String, dynamic>{'enabled': enabled});
  }

  Future<void> setForceSpeakerphoneOn(
      {ForceSpeakerType flag = ForceSpeakerType.DEFAULT}) async {
    await _channel.invokeMethod('setForceSpeakerphoneOn', <String, dynamic>{
      'flag': flag == ForceSpeakerType.DEFAULT
          ? 0
          : (flag == ForceSpeakerType.FORCE_ON ? 1 : -1)
    });
  }

  Future<void> enableProximitySensor(bool enabled) async {
    await _channel.invokeMethod(
        'enableProximitySensor', <String, dynamic>{'enabled': enabled});
  }

  Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingtone: ${e.message}';
    }
  }

  /// Start Ringback.
  Future<void> startRingback() async {
    try {
      await _channel.invokeMethod('startRingback');
    } on PlatformException catch (e) {
      throw 'Unable to startRingback: ${e.message}';
    }
  }

  /// Stop Ringback.
  Future<void> stopRingback() async {
    try {
      await _channel.invokeMethod('stopRingback');
    } on PlatformException catch (e) {
      throw 'Unable to stopRingback: ${e.message}';
    }
  }

  /// Check record permission.
  Future<String> checkRecordPermission() async {
    String response = "unknow";
    try {
      response = await _channel.invokeMethod('checkRecordPermission');
    } catch (e) {}

    return response;
  }

  /// Request record permission.
  Future<String> requestRecordPermission() async {
    String response = "unknow";
    try {
      response = await _channel.invokeMethod('requestRecordPermission');
    } catch (e) {}

    return response;
  }

  /// Check camera permission.
  Future<String> checkCameraPermission() async {
    String response = "unknow";
    try {
      response = await _channel.invokeMethod('checkCameraPermission');
    } catch (e) {}

    return response;
  }

  /// Request camera permission.
  Future<String> requestCameraPermission() async {
    String response = "unknow";
    try {
      response = await _channel.invokeMethod('requestCameraPermission');
    } catch (e) {}

    return response;
  }

  final StreamController<bool> onProximity = StreamController.broadcast();
  final StreamController<String> onAudioDeviceChanged =
      StreamController.broadcast();
  final StreamController<String> onAudioFocusChange =
      StreamController.broadcast();
  final StreamController<String> onMediaButton = StreamController.broadcast();

  void eventListener(dynamic data) {
    Map<dynamic, dynamic> event = data as Map<dynamic, dynamic>;
    print('Event ${event['event']} => ${event.toString()}');
    switch (event['event']) {
      case 'WiredHeadset': //wire headset is plugged
        bool isPlugged = event['isPlugged'];
        bool hasMic = event['hasMic'];
        String deviceName = event['deviceName'];
        print(
            "WiredHeadset:isPlugged:$isPlugged hasMic:$hasMic deviceName:$deviceName");
        break;
      case 'Proximity':
        bool isNear = event['isNear'];
        onProximity.add(isNear);
        break;
    }
  }
}
