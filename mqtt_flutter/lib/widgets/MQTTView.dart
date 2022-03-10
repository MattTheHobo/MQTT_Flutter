import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_flutter/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_flutter/mqtt/MQTTManager.dart';

class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  final TextEditingController _userTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    _userTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold =
        Scaffold(appBar: AppBar(title: Text('MQTT')), body: _buildColumn());
    return scaffold;
  }

  /*Widget buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('MQTT'),
      backgroundColor: Colors.greenAccent,
    );
  }*/

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        Text(
          'Messages:',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        _buildScrollableTextWith(currentAppState.getHistoryText)
      ],
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTextFieldWith(_hostTextController, 'Enter broker address',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildTextFieldWith(
              _topicTextController,
              'Enter a topic to subscribe or listen',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildTextFieldWith(_userTextController, 'Enter username',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.amberAccent,
              child: Text(status, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)),
        ),
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _topicTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _userTextController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 400,
        height: 300,
        child: SingleChildScrollView(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          reverse: true,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 4),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    void _resetButt() {
      setState(() {
        currentAppState.resetText();
      });
    }

    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
            style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 118, 62, 170),
                fixedSize: Size(20, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            child: const Text('Disconnect'),
            onPressed:
                state == MQTTAppConnectionState.connected ? _disconnect : null,
            style: ElevatedButton.styleFrom(
                primary: Colors.red,
                fixedSize: Size(20, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: ElevatedButton(
          child: const Text("Reset", style: TextStyle(color: Colors.black),),
          onPressed: _resetButt,
          style: ElevatedButton.styleFrom(
            primary: Colors.orangeAccent,
              fixedSize: Size(40, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
        )),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return ElevatedButton(
      child: const Text('Send', style: TextStyle(color: Colors.black)),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
      style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 243, 209, 14),
          fixedSize: Size(100, 30),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25))), //
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    /*String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }*/
    String osPrefix = 'Anonymous';

    if (_userTextController.text != '') {
      osPrefix = _userTextController.text;
    }
    manager = MQTTManager(
        host: _hostTextController.text,
        topic: _topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishMessage(String text) {
    String osPrefix = 'Anonymous';

    if (_userTextController.text != '') {
      osPrefix = _userTextController.text;
    }

    /*String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }*/
    final String message = osPrefix + ': ' + text;
    manager.publish(message);
    _messageTextController.clear();
  }
}
