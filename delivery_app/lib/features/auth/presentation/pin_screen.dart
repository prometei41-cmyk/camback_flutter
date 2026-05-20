import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String? _error;

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin');

    if (_enteredPin == savedPin) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _error = 'Неверный PIN';
        _enteredPin = '';
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _error = null;
      });
      if (_enteredPin.length == 4) {
        _checkPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Введите PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Введите 4-значный PIN',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length ? Colors.black : Colors.grey[300],
                  ),
                );
              }),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (int i = 1; i <= 9; i++)
                    ElevatedButton(
                      onPressed: () => _onNumberPressed(i.toString()),
                      child: Text(i.toString(), style: const TextStyle(fontSize: 24)),
                    ),
                  const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () => _onNumberPressed('0'),
                    child: const Text('0', style: TextStyle(fontSize: 24)),
                  ),
                  IconButton(
                    onPressed: _onBackspacePressed,
                    icon: const Icon(Icons.backspace, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
