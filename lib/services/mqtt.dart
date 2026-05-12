import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../encoding/item_qr_codec.dart';
import '../models/mqtt_connection.dart';

class MqttService {
  MqttService(this.connData, {required this.onItemsScanned}) {
    _initClient();
  }

  final Function(Iterable<String> barcodes) onItemsScanned;

  final MqttConnectionData connData;
  late final MqttClient _client;

  String _topic(String topic) => 'inventur_helper/${connData.topic}/$topic';

  void _initClient() {
    final clientId = 'inventur_helper-${DateTime.now().millisecondsSinceEpoch}';

    if (!kIsWeb) {
      final client = MqttServerClient.withPort(connData.host, clientId, connData.port);
      _client = client;

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
    } else {
      _client = MqttBrowserClient.withPort('ws://${connData.host}', clientId, connData.port);
    }

    _client.setProtocolV311();
  }

  void _listen() {
    _client.subscribe(_topic('#'), MqttQos.atMostOnce);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final MqttReceivedMessage<MqttMessage> message in messages) {
        final String topic = message.topic;
        final MqttMessage payload = message.payload;

        if (payload is MqttPublishMessage) {
          final String payloadString = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );

          if (topic == _topic('scan')) {
            debugPrint('MQTT received scan: $payloadString');
            onItemsScanned(itemQrCodec.decode(payloadString));
          }
        }
      }
    });
  }

  Future<bool> connectToBroker() async {
    try {
      await _client.connect(connData.username, connData.password);
    } catch (e) {
      debugPrint('MQTT connection: $e');
      _client.disconnect();
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('MQTT connection: Success');
      _listen();
      _sendMessage('status', _client.clientIdentifier);
      return true;
    } else {
      debugPrint('MQTT connection: Failed');
      _client.disconnect();
      return false;
    }
  }

  void _sendMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(_topic(topic), MqttQos.atLeastOnce, builder.payload!);
  }

  void publishScan(Iterable<String> barcodes) => _sendMessage('scan', itemQrCodec.encode(barcodes));
}
