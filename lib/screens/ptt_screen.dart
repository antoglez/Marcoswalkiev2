import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_alert_window/system_alert_window.dart';
import '../providers/ptt_provider.dart';

// Hecho por PGM y PEDROAI
class PTTScreen extends StatefulWidget {
  const PTTScreen({super.key});

  @override
  State<PTTScreen> createState() => _PTTScreenState();
}

class _PTTScreenState extends State<PTTScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    // Request permissions on init removed as per user request
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PTTProvider>(context);
    final selectedProfile = provider.selectedProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MarcosWalkie PTT', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Instrucciones',
            onPressed: () => _showHelpDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () => Navigator.pushNamed(context, '/profiles'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileSelector(provider),
              const Spacer(),
              _buildPTTButton(provider),
              const SizedBox(height: 30),
              _buildOverlayControls(context),
              const Spacer(),
              _buildStatusIndicator(provider),
              const SizedBox(height: 10),
              const Text('Hecho por PGM y PEDROAI', style: TextStyle(color: Colors.white24, fontSize: 10)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.layers),
          label: const Text('BOTÓN FLOTANTE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            bool hasPermission = await SystemAlertWindow.checkPermissions(prefMode: SystemWindowPrefMode.OVERLAY) ?? false;
            if (!hasPermission) {
              await SystemAlertWindow.requestPermissions(prefMode: SystemWindowPrefMode.OVERLAY);
            } else {
               SystemAlertWindow.showSystemWindow(
                  height: 150, 
                  width: 150,
                  gravity: SystemWindowGravity.TOP, // Changed from CENTER
                  prefMode: SystemWindowPrefMode.OVERLAY,
                  layoutParamFlags: [
                    SystemWindowFlags.FLAG_NOT_FOCUSABLE,
                    SystemWindowFlags.FLAG_NOT_TOUCH_MODAL,
                  ],
              );
            }
          },
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('CERRAR FLOTANTE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[900],
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
          }
        ),
      ],
    );
  }

  Widget _buildProfileSelector(PTTProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree_outlined, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.selectedProfile?.id,
                isExpanded: true,
                onChanged: (id) => id != null ? provider.selectProfile(id) : null,
                items: provider.profiles.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPTTButton(PTTProvider provider) {
    return GestureDetector(
      onPanDown: (_) => provider.startTransmission(),
      onPanEnd: (_) => provider.stopTransmission(),
      onPanCancel: () => provider.stopTransmission(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final isTransmitting = provider.isTransmitting;
          return Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTransmitting 
                  ? Theme.of(context).colorScheme.secondary 
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: isTransmitting 
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.5 * _pulseController.value) 
                      : Colors.black.withOpacity(0.3),
                  blurRadius: isTransmitting ? 40 : 20,
                  spreadRadius: isTransmitting ? 10 * _pulseController.value : 0,
                ),
              ],
              border: Border.all(
                color: isTransmitting 
                    ? Colors.white.withOpacity(0.5) 
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTransmitting ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color: isTransmitting ? Colors.white : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTransmitting ? 'HABLANDO' : 'PULSAR PARA HABLAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isTransmitting ? Colors.white : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(PTTProvider provider) {
    return Column(
      children: [
        Text(
          provider.isTransmitting ? 'TRANSMITIENDO...' : 'LISTO',
          style: TextStyle(
            color: provider.isTransmitting ? Colors.orange : Colors.greenAccent,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        if (provider.isTransmitting)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Suelta para dejar de hablar',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Instrucciones'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Configuración:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Ve a ajustes (icono ⚙️) para crear perfiles con los "Intents" de tu aplicación de Walkie Talkie.'),
              SizedBox(height: 10),
              Text('2. Uso Directo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Mantén pulsado el círculo central para hablar. Al soltar, se enviará la señal de detención.'),
              SizedBox(height: 10),
              Text('3. Botón Flotante:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Pulsa "BOTÓN FLOTANTE" para usar el PTT sobre otras aplicaciones. La primera vez se te pedirá permiso de superposición.'),
              SizedBox(height: 10),
              Text('4. Cierre:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Al cerrar o deslizar la app principal, la burbuja flotante desaparecerá automáticamente.'),
              SizedBox(height: 20),
              Divider(color: Colors.white10),
              SizedBox(height: 10),
              Center(child: Text('Software desarrollado por PGM y PEDROAI.', style: TextStyle(fontSize: 10, color: Colors.blueAccent))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ENTENDIDO', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
