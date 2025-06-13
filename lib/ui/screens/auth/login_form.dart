import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/user.dart';
import 'package:gasguard_mobile/ui/common/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
        String? userJson = prefs.getString('user_data');
        if (userJson != null) {
          User user = User.fromJson(json.decode(userJson));
          
          // Navegación después de la inicialización completa
          Future.microtask(() {
            Navigator.pushReplacementNamed(
              context, 
              AppRouter.dashboard,
              arguments: {'user': user},
            );
          });
        }
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
      // Verificar credenciales - versión demo
      bool isAuthenticated = await _authenticateUser(email, password);

      if (isAuthenticated) {
        User user = await _getUserData();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);

        _showSnackBar('¡Inicio de sesión exitoso!');

        await Future.delayed(const Duration(seconds: 1));

        // Navegar al dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.dashboard,
            arguments: {'user': user},
          );
        }
      } else {
        _showSnackBar('Credenciales incorrectas');
      }
    } catch (e) {
      _showSnackBar('Error al iniciar sesión: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para autenticar usuario (demo - SharedPreferences)
  Future<bool> _authenticateUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      final savedPassword = prefs.getString('user_password');
      
      if (userJson != null && savedPassword != null) {
        final userData = json.decode(userJson);
        final user = User.fromJson(userData);
        
        return user.email == email && savedPassword == password;
      }
      
      // Si no hay usuario guardado, permitir un usuario demo
      return email == 'demo@gasguard.com' && password == 'demo123';
    } catch (e) {
      print('Error al autenticar: $e');
      return false;
    }
  }

  // Método para obtener datos de usuario
  Future<User> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
      
      // Usuario demo como fallback
      return User(
        id: 'demo123',
        email: _emailController.text,
        name: 'Usuario Demo',
        deviceIds: ['device001', 'device002'],
      );
    } catch (e) {
      print('Error al obtener usuario: $e');
      // Usuario demo como fallback para error
      return User(
        id: 'demo123',
        email: _emailController.text,
        name: 'Usuario Demo',
        deviceIds: [],
      );
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