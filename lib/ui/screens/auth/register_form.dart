import 'package:flutter/material.dart';
import 'package:gasguard_mobile/ui/common/input_field.dart';
import 'package:gasguard_mobile/service/auth_service.dart';
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
  bool _isLoading = false;

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
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Create account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }

  void _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signUp(email, password);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('¡Cuenta creada exitosamente! Ahora puedes iniciar sesión');
        
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        Navigator.pushReplacementNamed(context, AppRouter.auth);

                
      } else {
        final data = response.data;
        _showSnackBar(data['message'] ?? 'Error al crear cuenta');
      }
    } catch (e) {
      print('Error de registro: $e');
      _showSnackBar('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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