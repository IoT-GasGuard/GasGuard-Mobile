import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gasguard_mobile/models/household_member.dart';

class AddEditMemberDialog extends StatefulWidget {
  final String title;
  final HouseholdMember? member;
  final Function(HouseholdMember) onSave;

  const AddEditMemberDialog({
    Key? key,
    required this.title,
    this.member,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditMemberDialog> createState() => _AddEditMemberDialogState();
}

class _AddEditMemberDialogState extends State<AddEditMemberDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEmergencyContact = false;
  bool _gasLeakAlerts = true;

  late TabController _tabController;
  int _currentStep = 0;
  final List<String> _steps = ['Información básica', 'Notificaciones'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.member?.fullName ?? '');
    _emailController = TextEditingController(text: widget.member?.email ?? '');
    _phoneController = TextEditingController(text: widget.member?.phoneNumber ?? '');
    _isEmergencyContact = widget.member?.isEmergencyContact ?? false;
    _gasLeakAlerts = widget.member?.gasLeakAlerts ?? true;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2133),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera del diálogo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2B3D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Indicador de pasos
                  Row(
                    children: List.generate(_steps.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentStep >= index
                                ? const Color(0xFF4ECDC4).withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _currentStep >= index
                                  ? const Color(0xFF4ECDC4)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _steps[index],
                              style: TextStyle(
                                color: _currentStep >= index
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Contenido del formulario
            SizedBox(
              height: 380, // Altura fija para evitar saltos
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Paso 1: Información básica
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserAvatar(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Nombre completo',
                          hint: 'Ingrese nombre completo',
                          icon: Icons.person,
                          validator: (value) => value.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Correo electrónico',
                          hint: 'Ingrese correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                          validator: (value) {
                            if (value.isEmpty) return 'Campo requerido';
                            if (!_isValidEmail(value)) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Número telefónico',
                          hint: 'Ingrese número telefónico',
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                          validator: (value) => value.isEmpty ? 'Campo requerido' : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _PhoneInputFormatter(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Paso 2: Configuración de notificaciones
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuración de alertas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Personaliza las notificaciones y alertas para este miembro',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildEnhancedSwitchItem(
                          title: 'Contacto de emergencia',
                          subtitle: 'Recibe notificaciones prioritarias y tiene acceso a funciones críticas de emergencia',
                          value: _isEmergencyContact,
                          icon: Icons.emergency,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() {
                              _isEmergencyContact = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedSwitchItem(
                          title: 'Alertas de fuga de gas',
                          subtitle: 'Recibe notificaciones cuando se detecten niveles peligrosos de gas',
                          value: _gasLeakAlerts,
                          icon: Icons.warning,
                          activeColor: const Color(0xFF4ECDC4),
                          onChanged: (value) {
                            setState(() {
                              _gasLeakAlerts = value;
                            });
                          },
                        ),

                        // Aquí puedes añadir más opciones de configuración
                        const SizedBox(height: 16),
                        _buildEnhancedSwitchItem(
                          title: 'Registro de actividad',
                          subtitle: 'Recibe informes periódicos de actividad del sistema',
                          value: true,
                          icon: Icons.assessment,
                          activeColor: const Color(0xFF4ECDC4),
                          onChanged: (value) {
                            // Implementar funcionalidad
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botones de navegación
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0A1A2A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Anterior'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentStep < _steps.length - 1 ? _nextStep : _handleSave,
                      icon: Icon(
                        _currentStep < _steps.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        size: 16,
                      ),
                      label: Text(
                        _currentStep < _steps.length - 1
                            ? 'Siguiente'
                            : (widget.member != null ? 'Guardar' : 'Añadir'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final String initials = _fullNameController.text.isNotEmpty
        ? _getInitials(_fullNameController.text)
        : '?';

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ECDC4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Añadir foto (opcional)',
            style: TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    String? errorMessage = validator?.call(controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A1A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorMessage != null
                  ? Colors.red
                  : const Color(0xFF2D4055),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            inputFormatters: inputFormatters,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF4ECDC4),
                size: 20,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.grey,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    controller.clear();
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? activeColor.withOpacity(0.1) : const Color(0xFF0A1A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.5) : const Color(0xFF2D4055),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: value ? activeColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: value ? activeColor : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_fullNameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          !_isValidEmail(_emailController.text.trim())) {
        _showErrorDialog('Por favor complete todos los campos correctamente.');
        return;
      }
    }

    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
        _tabController.animateTo(_currentStep);
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        _tabController.animateTo(_currentStep);
      }
    });
  }

  void _handleSave() {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    final member = HouseholdMember(
      id: widget.member?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      isEmergencyContact: _isEmergencyContact,
      gasLeakAlerts: _gasLeakAlerts,
      notificationsEnabled: _gasLeakAlerts,
    );

    widget.onSave(member);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Implementar formato de teléfono
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 0) formatted += '+';
      if (i == 2) formatted += ' ';
      if (i == 5 || i == 8) formatted += ' ';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}