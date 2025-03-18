import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuración del ESP32',
      home: WiFiConfigScreen(),
    );
  }
}

class WiFiConfigScreen extends StatefulWidget {
  @override
  _WiFiConfigScreenState createState() => _WiFiConfigScreenState();
}

class _WiFiConfigScreenState extends State<WiFiConfigScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> sendConfigData() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();

    print('📋 Datos capturados:');
    print('👉 SSID: $ssid');
    print('👉 Contraseña: ${'*' * password.length}'); // Ocultar por seguridad
    print('👉 Teléfono ingresado: $phoneNumber');

    // 👉 Validación del número de teléfono
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+52$phoneNumber';
      print('ℹ️ Número corregido con prefijo: $phoneNumber');
    }

    // 👉 Validación de campos vacíos
    if (ssid.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      _showMessage('⚠️ Todos los campos son obligatorios.');
      print('❌ Error: Uno o más campos están vacíos.');
      return;
    }

    // 👉 Dirección IP del ESP32 (Verifica que coincida con tu configuración)
    const esp32Ip = 'http://192.168.4.1';
    final url = Uri.parse('$esp32Ip/configure');

    try {
      print('🔗 Enviando datos al ESP32...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // 👈 Enviar datos en texto plano
        },
        body:
            'ssid=$ssid&password=$password&phone=$phoneNumber', // 👈 Enviar en formato correcto
      );

      print('🔍 Respuesta del ESP32 (Código HTTP): ${response.statusCode}');
      print('📄 Respuesta del ESP32 (Body): ${response.body}');

      if (response.statusCode == 200) {
        _showMessage('✅ Configuración enviada con éxito');
        print('✅ Configuración enviada correctamente');
      } else {
        _showMessage('❌ Error al enviar los datos');
        print('❌ Error en la respuesta del ESP32: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('⚠️ Error de conexión con el ESP32');
      print('❌ Error de conexión: $e');
    }
  }

  // 👉 Mostrar mensajes claros al usuario
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    print('📣 Mensaje mostrado al usuario: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar ESP32 Wi-Fi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(labelText: 'SSID de la red Wi-Fi'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña del Wi-Fi'),
              obscureText: true,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Número de teléfono'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('🟠 Botón "Enviar configuración" PRESIONADO');
                sendConfigData();
              },
              child: Text('Enviar configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
