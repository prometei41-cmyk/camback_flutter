import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  String? _emailError;
  String? _passwordError;
  String? _serverError;

  bool _isLoading = false;

  Future<void> _validate() async {
    print('LOGIN START');

    setState(() {
      _emailError = null;
      _passwordError = null;
      _serverError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    /*final prefs = await SharedPreferences.getInstance();
    await prefs.clear();*/

    if (email.isEmpty) {
      setState(() => _emailError = 'Введите email');
      return;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Некорректный email');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Введите пароль');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Логинимся — токен сохраняется внутри AuthRepository.login()
      await authRepository.login(email, password);

      // 2. Даем SharedPreferences время завершить запись
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() => _isLoading = false);
      print('LOGIN END');

      // 3. Переходим дальше
      Navigator.pushReplacementNamed(context, '/create_pin');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = e.toString();
      });
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Icon(Icons.lock_outline, size: 80, color: Colors.green),

              const SizedBox(height: 24),

              const Text(
                'Вход',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  errorText: _passwordError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_serverError != null)
                Text(
                  _serverError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _validate,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Войти'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/register');
                      },
                child: const Text('Создать аккаунт'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
