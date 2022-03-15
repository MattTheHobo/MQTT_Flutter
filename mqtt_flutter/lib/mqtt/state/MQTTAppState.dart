import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = ''; //_ = private
  String _historyText = '';

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = _historyText + '\n' + _receivedText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void resetText() {
    _historyText = '';
  }

  String get getReceivedText => _receivedText; //getter
  String get getHistoryText => _historyText; //getter
  MQTTAppConnectionState get getAppConnectionState =>
      _appConnectionState; //getter

}
