import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:gasguard_mobile/config/environment.dart';
import 'dart:async';

class StompWebSocketService {
  // 🔥 SINGLETON PATTERN
  static final StompWebSocketService _instance = StompWebSocketService._internal();
  factory StompWebSocketService() => _instance;
  StompWebSocketService._internal();

  StompClient? _stompClient;
  Function(Map<String, dynamic>)? onDataReceived;
  bool _isConnected = false;
  String? _deviceId;
  Timer? _reconnectTimer;
  Timer? _debounceTimer;
  
  // 🔥 CACHE DE ÚLTIMOS DATOS RECIBIDOS
  Map<String, Map<String, dynamic>> _lastDataCache = {};
  
  bool get isConnected => _isConnected;
  String? get currentDeviceId => _deviceId;

  // 🔥 MÉTODO PARA OBTENER ÚLTIMO DATO CACHEADO
  Map<String, dynamic>? getLastData(String deviceId) {
    return _lastDataCache[deviceId];
  }

  Future<void> connect(String deviceId) async {
    // Si ya está conectado al mismo dispositivo, no reconectar
    if (_isConnected && _deviceId == deviceId) {
      print('🔄 Ya conectado a $deviceId, enviando datos cacheados...');
      _sendCachedData(deviceId);
      return;
    }
    
    _deviceId = deviceId;
    await _connectWithRetry();
  }

  // 🔥 ENVIAR DATOS CACHEADOS INMEDIATAMENTE
  void _sendCachedData(String deviceId) {
    final cachedData = _lastDataCache[deviceId];
    if (cachedData != null && onDataReceived != null) {
      print('📤 Enviando datos cacheados para $deviceId: $cachedData');
      onDataReceived!(cachedData);
    }
  }
  
  Future<void> _connectWithRetry() async {
    try {
      final wsUrl = Environment.production
          ? 'wss://gasguard-api-282272338419.southamerica-west1.run.app/ws/monitoring'
          : 'ws://10.0.2.2:8080/ws/monitoring';
      
      print('🔌 Conectando STOMP WebSocket a: $wsUrl para deviceId: $_deviceId');
      
      // Desconectar cliente anterior si existe
      if (_stompClient != null) {
        _stompClient!.deactivate();
      }
      
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
    
    // 🔥 ENVIAR DATOS CACHEADOS INMEDIATAMENTE DESPUÉS DE CONECTAR
    if (_deviceId != null) {
      _sendCachedData(_deviceId!);
    }
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
        
        // 🔥 GUARDAR EN CACHE
        _lastDataCache[messageDeviceId] = processedData;
        
        // Enviar a callback si existe
        onDataReceived?.call(processedData);
      }
    } catch (e) {
      print('❌ Error procesando mensaje STOMP de $_deviceId: $e');
    }
  }

  // 🔥 AGREGAR TODOS LOS MÉTODOS CALLBACK FALTANTES
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
    _scheduleReconnect();
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

  // 🔥 MÉTODO MODIFICADO - NO DESCONECTAR COMPLETAMENTE
  void disconnect() {
    print('🔌 Pausando conexión STOMP (manteniendo cache)');
    onDataReceived = null; // Solo remover callback
    // NO desactivar el cliente para mantener la conexión
  }

  // Métodos para lighting commands...
  Future<bool> sendLightingCommand({
    required String deviceId,
    required int value,
    required bool auto,
    bool debounce = true,
  }) async {
    if (!_isConnected || _stompClient == null) {
      print('❌ STOMP no conectado, no se puede enviar comando');
      return false;
    }

    try {
      if (debounce) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(milliseconds: 250), () {
          _sendActualCommand(deviceId, value, auto);
        });
        return true;
      } else {
        return _sendActualCommand(deviceId, value, auto);
      }
    } catch (e) {
      print('❌ Error enviando comando de iluminación: $e');
      return false;
    }
  }
  
  bool _sendActualCommand(String deviceId, int value, bool auto) {
    try {
      final lightingData = {
        'auto': auto ? 1 : 0,
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
}