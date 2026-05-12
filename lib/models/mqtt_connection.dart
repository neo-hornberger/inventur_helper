class MqttConnectionData {
  final MqttConnectionType type;
  final String host;
  final int port;
  final String? username;
  final String? password;
  final String topic;
  final String? encryptionPassword;

  MqttConnectionData({
    this.type = MqttConnectionType.tcp,
    required this.host,
    this.port = 1883,
    this.username,
    this.password,
    required this.topic,
    this.encryptionPassword,
  });
}

enum MqttConnectionType {
  tcp('mqtt://'),
  tls('mqtts://'),
  websocket('ws://'),
  wss('wss://');

  const MqttConnectionType(this.display);

  final String display;

  static Set<MqttConnectionType> browserValues = {websocket, wss};
}
