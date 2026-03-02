import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'providers/ptt_provider.dart';
import 'screens/ptt_screen.dart';
import 'screens/profile_list_screen.dart';
import 'widgets/overlay_widget.dart';

@pragma('vm:entry-point')
// Hecho por PGM y PEDROAI
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWidget(),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final pttProvider = PTTProvider();
  
  // Setup Isolate communication
  final receivePort = ReceivePort();
  IsolateNameServer.removePortNameMapping('PTT_PORT');
  IsolateNameServer.registerPortWithName(receivePort.sendPort, 'PTT_PORT');
  
  receivePort.listen((message) {
    if (message == "START") {
      pttProvider.startTransmission();
    } else if (message == "STOP") {
      pttProvider.stopTransmission();
    }
  });

  runApp(
    ChangeNotifierProvider<PTTProvider>.value(
      value: pttProvider,
      child: const MarcosWalkieApp(),
    ),
  );
}

class MarcosWalkieApp extends StatefulWidget {
  const MarcosWalkieApp({super.key});

  @override
  State<MarcosWalkieApp> createState() => _MarcosWalkieAppState();
}

class _MarcosWalkieAppState extends State<MarcosWalkieApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarcosWalkie PTT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFFFF5722),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const PTTScreen(),
      routes: {
        '/profiles': (context) => const ProfileListScreen(),
      },
    );
  }
}
