import 'package:flutter/material.dart';
import '../../../api/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _serverError;

  bool _isLoading = false;

  void _validate() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _serverError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // Name
    if (name.isEmpty) {
      setState(() => _nameError = 'Введите имя');
      return;
    }

    // Email
    if (email.isEmpty) {
      setState(() => _emailError = 'Введите email');
      return;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Некорректный email');
      return;
    }

    // Password
    if (password.isEmpty) {
      setState(() => _passwordError = 'Введите пароль');
      return;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Пароль должен быть не менее 6 символов');
      return;
    }

    // Confirm password
    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Повторите пароль');
      return;
    } else if (confirm != password) {
      setState(() => _confirmError = 'Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authRepository.register(email, password, name);

      setState(() => _isLoading = false);

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _serverError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

              const Icon(Icons.person_add_alt_1, size: 80, color: Colors.green),

              const SizedBox(height: 24),

              const Text(
                'Создать аккаунт',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // NAME FIELD
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // EMAIL FIELD
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

              // PASSWORD FIELD
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

              // CONFIRM PASSWORD FIELD
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Повторите пароль',
                  errorText: _confirmError,
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
                    : const Text('Зарегистрироваться'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('У меня уже есть аккаунт'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
