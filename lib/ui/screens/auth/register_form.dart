import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/user.dart';
import 'package:gasguard_mobile/ui/common/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/app_router.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Nombre
        CustomInputField(
          label: 'Full Name',
          controller: _nameController,
          hintText: 'John Doe',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 24),
        
        // Campo Email
        CustomInputField(
          label: 'Email',
          controller: _emailController,
          hintText: 'example@demo.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        
        // Campo Password
        CustomInputField(
          label: 'Password',
          controller: _passwordController,
          hintText: '••••••••',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 32),
        _buildRegisterButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _handleRegister();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Create account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleRegister() {

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos');
      return;
    }

    _showSnackBar('Creando cuenta...');

    // Crear objeto User
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      deviceIds: [], // Usuario nuevo sin dispositivos
    );

    // Guardar el usuario simuldo
    _saveUser(newUser, password).then((_) {
      // Una vez guardado, navegar al dashboard
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context, 
          AppRouter.dashboard,
          arguments: {'user': newUser},
        );
      });
    }).catchError((error) {
      _showSnackBar('Error al crear cuenta: $error');
    });
  }

  // Método para guardar usuario en SharedPreferences)
  Future<void> _saveUser(User user, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_data', json.encode(user.toJson()));
      
      await prefs.setString('user_password', password);
      
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Error al guardar usuario: $e');
      throw Exception('No se pudo guardar la cuenta');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}