import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../models/mqtt_connection.dart';

MqttClient newMqttClient(MqttConnectionData connData, String clientId) {
  final client = MqttServerClient.withPort(connData.host, clientId, connData.port);

  switch (connData.type) {
    case MqttConnectionType.tcp:
      client.useWebSocket = false;
      client.secure = false;
    case MqttConnectionType.tls:
      client.useWebSocket = false;
      client.secure = true;
    case MqttConnectionType.websocket:
      client.useWebSocket = true;
      client.secure = false;

      client.server = 'ws://${client.server}';
    case MqttConnectionType.wss:
      client.useWebSocket = true;
      client.secure = true;

      client.server = 'wss://${client.server}';
  }

  return client;
}
