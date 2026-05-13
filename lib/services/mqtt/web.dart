import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../models/mqtt_connection.dart';

MqttClient newMqttClient(MqttConnectionData connData, String clientId) =>
    MqttBrowserClient.withPort('ws://${connData.host}', clientId, connData.port);
