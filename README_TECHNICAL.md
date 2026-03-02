# 🛠 Especificaciones Técnicas Detalladas - MarcosWalkie PTT v2

Este documento está destinado a desarrolladores que deseen entender las entrañas de la aplicación para modificarla o ampliarla.

## 🏗 Arquitectura General

La aplicación sigue el patrón **Provider** para la gestión de estado y desacoplamiento de la lógica de negocio de la interfaz de usuario.

### 1. Núcleo de Lógica: `PTTProvider` (`lib/providers/ptt_provider.dart`)
Es el cerebro de la aplicación. Gestiona:
- **Persistencia:** Usa `shared_preferences` para guardar perfiles (`ptt_profiles`), el perfil seleccionado y los códigos de teclas USB globales.
- **Transmisión de Intents:** 
  - `startTransmission()`: Activa el PTT. Dispara un `AndroidIntent` con la acción configurada en el perfil. También soporta un `MethodChannel` especial para control de volumen (`METHOD_CHANNEL_VOLUME_UP`).
  - `stopTransmission()`: Detiene el PTT enviando el Intent de parada.
- **Hardware USB:** Almacena `_globalStartKeyCode` y `_globalStopKeyCode`.

### 2. Interfaz Principal: `PTTScreen` (`lib/screens/ptt_screen.dart`)
Además de la UI, implementa la captura de Low-Level Events:
- **`RawKeyboardListener`:** Envuelve toda la pantalla para capturar eventos de teclado/HID incluso si no hay un campo de texto enfocado (usando un `FocusNode` con `autofocus: true`).
- **Lógica de Pulsador:**
  - `RawKeyDownEvent`: Dispara `provider.startTransmission()` si la tecla coincide con el código guardado.
  - `RawKeyUpEvent`: Dispara `provider.stopTransmission()` al soltar la tecla.

### 3. Sistema de Botón Flotante (Overlay)
- **`main.dart` & `overlayMain`:** La app usa un punto de entrada secundario `@pragma('vm:entry-point')` para el proceso del overlay.
- **Comunicación entre Procesos:** Usa `IsolateNameServer` y una `ReceivePort` llamada `'PTT_PORT'` para que el botón flotante pueda enviar comandos de "START/STOP" al proceso principal de la app.
- **`OverlayWidget` (`lib/widgets/overlay_widget.dart`):** Un widget minimalista que se dibuja sobre otras apps usando la librería `system_alert_window`.

### 4. Mapeo USB: `USBMappingScreen` (`lib/screens/usb_mapping_screen.dart`)
Una pantalla dedicada a "escuchar" la siguiente tecla que se pulse. Devuelve el `keyId` de la `LogicalKeyboardKey` capturada mediante `Navigator.pop(context, event.logicalKey.keyId)`.

## 🚀 Flujos Detallados

### Ciclo de vida del PTT vía USB:
1. `PTTScreen` recibe un `RawKeyDownEvent`.
2. Se compara `event.logicalKey.keyId` con `provider.globalStartKeyCode`.
3. Si coincide, se llama a `provider.startTransmission()`.
4. `provider` marca `_isTransmitting = true` y lanza el `AndroidIntent` (Broadcast + Launch).
5. Al soltar (KeyUp), se repite el proceso para detener la transmisión.

### Flujo del Botón Flotante:
1. El usuario pulsa el overlay.
2. `OverlayWidget` busca el `SendPort` en el `IsolateNameServer`.
3. Envía el mensaje `"START"` o `"STOP"`.
4. El `main.dart` recibe el mensaje en su `receivePort.listen` y ejecuta la función correspondiente en el `PTTProvider`.

## 📦 Dependencias Críticas
- `android_intent_plus`: Para comunicarnos con otras apps de Walkie Talkie.
- `system_alert_window`: Para la funcionalidad de burbuja flotante.
- `provider`: Inyección de dependencias y reactividad.

---
*Si vas a modificar los Intents, asegúrate de revisar la documentación de la app de destino (ej. Zello) para conocer las "Actions" y "Extras" correctos.*
