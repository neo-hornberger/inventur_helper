import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventur_helper/models/mqtt_connection.dart';

class BrokerSettingsPage extends StatefulWidget {
  const BrokerSettingsPage({super.key});

  @override
  State<BrokerSettingsPage> createState() => _BrokerSettingsPageState();
}

class _BrokerSettingsPageState extends State<BrokerSettingsPage> {
  final GlobalKey<FormFieldState<MqttConnectionType>> _brokerConTypeKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _brokerHostKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _brokerPortKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _usernameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _roomNameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _roomPasswordKey = GlobalKey();

  void _onSubmit() {
    final MqttConnectionType? brokerType = _brokerConTypeKey.currentState?.value;
    final String? brokerHost = _brokerHostKey.currentState?.value;
    final String? brokerPort = _brokerPortKey.currentState?.value;
    final String? username = _usernameKey.currentState?.value;
    final String? password = _passwordKey.currentState?.value;
    final String? roomName = _roomNameKey.currentState?.value;
    final String? roomPassword = _roomPasswordKey.currentState?.value;

    if ((brokerHost == null || brokerHost.isEmpty) || (roomName == null || roomName.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    Navigator.pop(
      context,
      MqttConnectionData(
        type: brokerType ?? MqttConnectionType.tcp,
        host: brokerHost,
        port: int.tryParse(brokerPort ?? '1883') ?? 1883,
        username: username,
        password: password,
        topic: roomName,
        encryptionPassword: roomPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broker Settings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
        child: Column(
          children: [
            const Text('Connection Settings'),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<MqttConnectionType>(
                    key: _brokerConTypeKey,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: (!kIsWeb ? MqttConnectionType.values : MqttConnectionType.browserValues)
                        .map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.display.toUpperCase()),
                          );
                        })
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    key: _brokerHostKey,
                    decoration: const InputDecoration(labelText: 'Host'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    key: _brokerPortKey,
                    decoration: const InputDecoration(labelText: 'Port'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextFormField(
              key: _usernameKey,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              key: _passwordKey,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            const Text('Room Settings'),
            TextFormField(
              key: _roomNameKey,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            TextFormField(
              key: _roomPasswordKey,
              decoration: const InputDecoration(labelText: 'Room Password'),
              obscureText: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        child: const Icon(Icons.save),
      ),
    );
  }
}
