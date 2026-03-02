import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

// Hecho por PGM y PEDROAI
class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isTransmitting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _notifyMain(bool isStart) async {
    try {
      final SendPort? sendPort = IsolateNameServer.lookupPortByName('PTT_PORT');
      if (sendPort != null) {
        sendPort.send(isStart ? "START" : "STOP");
      }
    } catch (e) {
      debugPrint("Overlay Port Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onPanDown: (_) {
              setState(() { _isTransmitting = true; });
              _notifyMain(true);
            },
            onPanEnd: (_) {
               setState(() { _isTransmitting = false; });
               _notifyMain(false);
            },
            onPanCancel: () {
              setState(() { _isTransmitting = false; });
              _notifyMain(false);
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTransmitting 
                        ? const Color(0xFFFF5722) 
                        : const Color(0xFF2196F3).withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: _isTransmitting 
                            ? const Color(0xFFFF5722).withOpacity(0.5 * _pulseController.value) 
                            : Colors.black.withOpacity(0.5),
                        blurRadius: _isTransmitting ? 30 : 15,
                        spreadRadius: _isTransmitting ? 10 * _pulseController.value : 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
