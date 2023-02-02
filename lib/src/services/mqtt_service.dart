import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  init() {
    client = MqttServerClient.withPort('192.168.206.41', '', 1883);
    client.onConnected = onConnect;
    client.autoReconnect = true;
    final connMess = MqttConnectMessage()
        .withClientIdentifier('pos1')
        .withWillTopic(
            'POS_TRANSACTIONS') // If you set this you must set a will message
        .withWillMessage('Pos message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
  }

  connect() async {
    try {
      await client.connect('pos', 'pos');
    } on Exception catch (e) {
      debugPrint('EXAMPLE::client exception - $e');
      client.disconnect();
    }
  }

  onConnect() {
    debugPrint('MQTT::connected ');
  }
}
