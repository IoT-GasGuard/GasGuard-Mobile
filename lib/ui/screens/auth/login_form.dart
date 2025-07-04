import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/user.dart';
import 'package:gasguard_mobile/ui/common/input_field.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import 'package:gasguard_mobile/service/auth_service.dart';
import '../../../utils/app_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    try {
      String? token = await StorageHelper.getToken();
      User? user = await StorageHelper.getUser();
      
      if (token != null && user != null) {
        // Usuario ya logueado, navegar al dashboard
        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context, 
            AppRouter.dashboard,
            arguments: {'user': user},
          );
        });
      }
    } catch (e) {
      print('Error al verificar sesión: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),
        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showSnackBar('Función no implementada en la demo');
            },
            child: Text(
              'Forgot password?',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Botón Login
        _buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signIn(email, password);

      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'] ?? '';
        await StorageHelper.saveToken(token);

        User user = User(
          id: data['id']?.toString() ?? '',
          email: email,
          name: data['profile']?['name'] ?? 'Usuario',
          phoneNumber: data['profile']?['phone_number'],
          profileId: data['profileId']?.toString() ?? '',
        );
        
        await StorageHelper.saveUser(user);

        _showSnackBar('¡Inicio de sesión exitoso!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.dashboard,
            arguments: {'user': user},
          );
        }
      }
    } on DioException catch (e) {
      String errorMsg = 'Credenciales incorrectas';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'];
        }
      }
      _showSnackBar(errorMsg);
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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