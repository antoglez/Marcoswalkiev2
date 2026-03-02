import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:system_alert_window/system_alert_window.dart';
import '../providers/ptt_provider.dart';
import 'usb_mapping_screen.dart';

// Hecho por PGM y PEDROAI
class PTTScreen extends StatefulWidget {
  const PTTScreen({super.key});

  @override
  State<PTTScreen> createState() => _PTTScreenState();
}

class _PTTScreenState extends State<PTTScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PTTProvider>(context);
    final selectedProfile = provider.selectedProfile;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (selectedProfile == null) return;
        
        final startCode = provider.globalStartKeyCode;
        final stopCode = provider.globalStopKeyCode;

        if (startCode != null && event.logicalKey.keyId == startCode) {
          if (event is RawKeyDownEvent && !provider.isTransmitting) {
            provider.startTransmission();
          }
        }
        
        if (startCode != null && event.logicalKey.keyId == startCode && event is RawKeyUpEvent) {
          provider.stopTransmission();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MarcosWalkie PTT', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.usb_rounded),
              tooltip: 'Configurar USB PTT',
              onPressed: () => _showUSBSettings(context, provider),
            ),
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
      ),
    );
  }

  Widget _buildOverlayControls(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
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
                  gravity: SystemWindowGravity.TOP,
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

  void _showUSBSettings(BuildContext context, PTTProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONFIGURACIÓN USB GENERAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 8),
              const Text('Configura aquí tus botones externos para todos los perfiles.', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              _buildModalMappingButton(
                context, 
                'BOTÓN PUSH (HABLAR)', 
                provider.globalStartKeyCode,
                (code) async {
                  await provider.setGlobalKeyCodes(code, provider.globalStopKeyCode);
                  setModalState(() {});
                }
              ),
              const SizedBox(height: 12),
              _buildModalMappingButton(
                context, 
                'BOTÓN RELEASE (SOLTAR)', 
                provider.globalStopKeyCode,
                (code) async {
                  await provider.setGlobalKeyCodes(provider.globalStartKeyCode, code);
                  setModalState(() {});
                }
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CERRAR', style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalMappingButton(BuildContext context, String label, int? code, Function(int) onCaptured) {
    return ListTile(
      tileColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: Text(code == null ? 'No configurado' : 'Código: $code', 
        style: TextStyle(color: code == null ? Colors.white54 : Colors.greenAccent)),
      trailing: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push<int>(
            context,
            MaterialPageRoute(builder: (context) => USBMappingScreen(title: label)),
          );
          if (result != null) onCaptured(result);
        },
        child: const Text('MAPEAR'),
      ),
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Perfiles:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Usa el icono de ajustes (⚙️) para configurar los "Intents" de cada aplicación de Walkie Talkie.'),
              SizedBox(height: 10),
              Text('2. Micrófono USB:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Configura tus botones USB pulsando el icono del enchufe (🔌). Este ajuste es global para todos los perfiles.'),
              SizedBox(height: 10),
              Text('3. Uso Directo:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Mantén pulsado el círculo central para hablar. Al soltar, se enviará la señal de detención.'),
              SizedBox(height: 10),
              Text('4. Botón Flotante:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Pulsa "BOTÓN FLOTANTE" para usar el PTT sobre otras aplicaciones. Requiere permiso de superposición.'),
              SizedBox(height: 10),
              Text('5. Cierre:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Al cerrar la app, la burbuja flotante desaparecerá automáticamente.'),
              SizedBox(height: 20),
              _buildFooter(),
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

  Widget _buildFooter() {
     return const Column(
       children: [
         Divider(color: Colors.white10),
         SizedBox(height: 10),
         Center(child: Text('Software desarrollado por PGM y PEDROAI.', style: TextStyle(fontSize: 10, color: Colors.blueAccent))),
       ],
     );
  }
}
