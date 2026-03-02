import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class USBMappingScreen extends StatefulWidget {
  final String title;
  const USBMappingScreen({super.key, required this.title});

  @override
  State<USBMappingScreen> createState() => _USBMappingScreenState();
}

class _USBMappingScreenState extends State<USBMappingScreen> {
  int? _capturedKeyCode;
  bool _isListening = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _capturedKeyCode = null;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (_isListening && event is RawKeyDownEvent) {
            setState(() {
              _capturedKeyCode = event.logicalKey.keyId;
              _isListening = false;
            });
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isListening ? Icons.mic : Icons.usb,
                size: 80,
                color: _isListening ? Colors.redAccent : Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              Text(
                _isListening 
                  ? 'PULSA EL BOTÓN DE TU MICRO USB...' 
                  : (_capturedKeyCode != null 
                      ? 'CÓDIGO DETECTADO: $_capturedKeyCode' 
                      : 'LISTO PARA MAPEAR'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_isListening)
                ElevatedButton.icon(
                  onPressed: _startListening,
                  icon: const Icon(Icons.search),
                  label: Text(_capturedKeyCode == null ? 'DETECTAR BOTÓN' : 'REPETIR DETECCIÓN'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              const SizedBox(height: 20),
              if (_capturedKeyCode != null && !_isListening)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _capturedKeyCode),
                  icon: const Icon(Icons.check),
                  label: const Text('CONFIRMAR Y GUARDAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
