import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:gasguard_mobile/config/environment.dart';
import 'dart:async';

class StompWebSocketService {
  StompClient? _stompClient;
  Function(Map<String, dynamic>)? onDataReceived;
  bool _isConnected = false;
  String? _deviceId;
  Timer? _reconnectTimer;
  Timer? _debounceTimer; // Timer para debounce
  
  bool get isConnected => _isConnected;

  Future<void> connect(String deviceId) async {
    _deviceId = deviceId;
    await _connectWithRetry();
  }
  
  Future<void> _connectWithRetry() async {
    try {
      final wsUrl = Environment.production
          ? 'wss://gasguard-api-282272338419.southamerica-west1.run.app/ws/monitoring'
          : 'ws://10.0.2.2:8080/ws/monitoring';
      
      print('🔌 Conectando STOMP WebSocket a: $wsUrl para deviceId: $_deviceId');
      
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnect,
          onWebSocketError: _onWebSocketError,
          onWebSocketDone: _onWebSocketDone,
          onStompError: _onStompError,
          onDisconnect: _onDisconnect,
          stompConnectHeaders: {},
          webSocketConnectHeaders: {},
          heartbeatIncoming: Duration(seconds: 10),
          heartbeatOutgoing: Duration(seconds: 10),
        ),
      );
      
      _stompClient!.activate();
      
    } catch (e) {
      print('❌ Error al conectar STOMP: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }
  
  void _onConnect(StompFrame frame) {
    print('✅ STOMP conectado');
    _isConnected = true;
    
    // Suscribirse al tópico de gas
    final topicPath = '/topic/gas/$_deviceId';
    _stompClient!.subscribe(
      destination: topicPath,
      callback: _onMessage,
    );
    
    print('✅ Suscrito al tópico dinámico: $topicPath');
  }

  void _onMessage(StompFrame frame) {
    try {
      print('📥 Mensaje STOMP recibido de $_deviceId: ${frame.body}');

      if (frame.body != null) {
        final jsonData = jsonDecode(frame.body!);
        print('✅ Datos procesados de $_deviceId: $jsonData');

        final messageDeviceId = jsonData['deviceId'];
        if (messageDeviceId != _deviceId) {
          print('⚠️ Mensaje de dispositivo diferente: $messageDeviceId vs $_deviceId');
          return;
        }

        final processedData = {
          'deviceId': messageDeviceId,
          'ppm': jsonData['ppm'] ?? 0.0,
          'value': jsonData['value'] ?? jsonData['ppm'] ?? 0.0,
          'status': jsonData['status'] ?? 'NORMAL',
          'threshold': jsonData['threshold'] ?? 1.0,
          'timestamp': jsonData['timestamp'] ?? DateTime.now().toIso8601String(),
          'message': jsonData['message'] ?? '',
        };

        print('🔄 Datos procesados finales: $processedData');
        onDataReceived?.call(processedData);
      }
    } catch (e) {
      print('❌ Error procesando mensaje STOMP de $_deviceId: $e');
    }
  }

  // 🔥 MÉTODO NUEVO: Enviar comando de iluminación por STOMP
  Future<bool> sendLightingCommand({
    required String deviceId,
    required int value,
    required bool auto,
    bool debounce = true, // Parámetro nuevo para activar/desactivar debounce
  }) async {
    if (!_isConnected || _stompClient == null) {
      print('❌ STOMP no conectado, no se puede enviar comando');
      return false;
    }

    try {
      // Cancelar timer anterior si existe
      if (debounce) {
        _debounceTimer?.cancel();
        
        // Programar envío después de un breve retraso
        _debounceTimer = Timer(Duration(milliseconds: 250), () {
          _sendActualCommand(deviceId, value, auto);
        });
        return true; // Devolvemos true aunque realmente se enviará después
      } else {
        // Enviar inmediatamente (sin debounce)
        return _sendActualCommand(deviceId, value, auto);
      }
    } catch (e) {
      print('❌ Error enviando comando de iluminación: $e');
      return false;
    }
  }
  
  // Método privado que realiza el envío real
  bool _sendActualCommand(String deviceId, int value, bool auto) {
    try {
      // Formato adaptado para el ESP32 que usa MQTT
      final lightingData = {
        'auto': auto ? 1 : 0,  // ESP32 espera 0 o 1
        'value': value,
        'deviceId': deviceId,
      };

      print('💡 Enviando comando de luz por STOMP: $lightingData');

      _stompClient!.send(
        destination: '/app/lighting',
        body: jsonEncode(lightingData),
      );

      print('✅ Comando de iluminación enviado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error enviando comando real: $e');
      return false;
    }
  }
  
  void _onWebSocketError(dynamic error) {
    print('❌ WebSocket error para $_deviceId: $error');
    _isConnected = false;
    _scheduleReconnect();
  }
  
  void _onWebSocketDone() {
    print('🔌 WebSocket cerrado para $_deviceId - intentando reconectar...');
    _isConnected = false;
    _scheduleReconnect();
  }
  
  void _onStompError(StompFrame frame) {
    print('❌ STOMP error para $_deviceId: ${frame.body}');
    _isConnected = false;
    _scheduleReconnect();
  }
  
  void _onDisconnect(StompFrame frame) {
    print('🔌 STOMP desconectado para $_deviceId');
    _isConnected = false;
  }
  
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (_deviceId != null) {
        print('🔄 Reintentando conexión STOMP para $_deviceId...');
        _connectWithRetry();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    if (_stompClient != null) {
      print('🛑 Desconectando STOMP para $_deviceId');
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
  }
}