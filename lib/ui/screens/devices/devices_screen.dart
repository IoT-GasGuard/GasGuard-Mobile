import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/ui/screens/devices/components/device_item.dart';
import 'package:gasguard_mobile/service/device_service.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import '../../../utils/app_router.dart';
import '../../../utils/top_menu.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener el usuario actual para conseguir su profileId
      final user = await StorageHelper.getUser();
      if (user == null || user.profileId.isEmpty) {
        setState(() {
          _error = 'No se pudo obtener información del usuario';
          _isLoading = false;
        });
        return;
      }

      // Llamar al backend para obtener dispositivos
      final response = await DeviceService.getDevicesByProfile(user.profileId);

      if (response.statusCode == 200) {
        final List<dynamic> devicesJson = response.data;
        final List<Device> devices = devicesJson
            .map((json) => Device.fromJson(json))
            .toList();

        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar dispositivos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header con el logo y menú
            AppHeader(
              title: 'Dispositivos',
              onMenuPressed: () => _showTopMenu(),
            ),

            // Contenido principal
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2B3D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis dispositivos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isLoading && _error == null)
                            Text(
                              '${_devices.length} dispositivos',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Lista de dispositivos
                      Expanded(
                        child: _isLoading
                            ? _buildLoadingState()
                            : _error != null
                                ? _buildErrorState()
                                : _devices.isEmpty
                                    ? _buildEmptyState()
                                    : _buildDevicesList(),
                      ),

                      // Botón para añadir dispositivo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToAddDevice(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ECDC4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Añadir dispositivo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF4ECDC4),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando dispositivos...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar errores
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Error desconocido',
            style: TextStyle(
              color: Colors.red.withOpacity(0.7),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDevices,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar cuando no hay dispositivos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron dispositivos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer dispositivo para comenzar a monitorear',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget para mostrar la lista de dispositivos
  Widget _buildDevicesList() {
    return RefreshIndicator(
      onRefresh: _loadDevices,
      backgroundColor: const Color(0xFF1A2B3D),
      color: const Color(0xFF4ECDC4),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: DeviceItem(
              device: device,
              onTap: () => _navigateToDeviceDetail(context, device),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDeviceDetail(BuildContext context, Device device) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.deviceDetail,
      arguments: {'device': device},
    );
    
    // Recargar la lista cuando se regrese con un resultado
    if (result != null) {
      _loadDevices();
      
      // Verificar si el dispositivo fue eliminado
      if (result is Map && result['action'] == 'deleted') {
        final deviceName = result['deviceName'] ?? 'El dispositivo';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deviceName ha sido eliminado correctamente'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Navegar a la pantalla para añadir dispositivo
  void _navigateToAddDevice(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.deviceDetail,
    );
    
    // Si hay un resultado, recargar la lista
    if (result != null) { // 👈 Cambia esta condición para aceptar cualquier resultado
      _loadDevices();
    }
  }

  // Muestra el menú superior
  void _showTopMenu() {
    TopMenu.showMenu(context);
  }
}