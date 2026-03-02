# MarcosWalkie PTT v2 🚀

MarcosWalkie es una aplicación de Push-To-Talk (PTT) diseñada para centralizar y facilitar el uso de múltiples aplicaciones de Walkie Talkie (como Zello, etc.) mediante botones externos y una interfaz simplificada.

## 🛠 Especificaciones Técnicas

- **Framework:** Flutter 3.32.8
- **Lenguaje:** Dart
- **Plataforma:** Android (SDK 36.0.0)
- **Gestión de Estado:** `provider`
- **Persistencia:** `shared_preferences`
- **Integración de Hardware:** Captura de eventos HID (Human Interface Device) mediante `RawKeyboardListener`.
- **Características Avanzadas:** 
  - Ventana flotante (Overlay) mediante `system_alert_window`.
  - Despacho de `Intents` personalizados por perfil.
  - Configuración global de hardware USB.

## 👶 Guía de Uso para Tontos (Manual Básico)

¡Bienvenido! Si no quieres complicarte la vida, sigue estos pasos:

1. **Instalación:** Simplemente descarga el archivo `supermarcoswalkie.apk` que verás en la raíz de este repositorio. Cópialo a tu móvil Android e instálalo. ¡Listo!
2. **Abrir la app:** Busca el icono de **MarcosWalkie** y ábrelo.
3. **Configurar el Micro USB (Importante):**
   - Si tienes un micrófono o botón USB, verás un icono de un **enchufe** (🔌) arriba a la derecha. Dale ahí.
   - Pulsa "MAPEAR" en el botón de hablar, y presiona el botón físico de tu micro.
   - Pulsa "MAPEAR" en el botón de soltar, y suelta el botón de tu micro.
   - ¡Ya está! Ahora la app sabe qué botón usar.
4. **Perfiles:**
   - La app usa "perfiles" para saber a qué app de Walkie Talkie debe enviar la señal.
   - Dale al icono del **engranaje** (⚙️) para crear o editar uno.
   - Solo tienes que poner el nombre y las "acciones" que te diga el manual de tu otra app (ej: Zello).
5. **A hablar:**
   - En la pantalla principal, selecciona el perfil que quieras.
   - Mantén pulsado el **círculo grande central** para hablar, o usa tu botón USB.
   - Si quieres usarlo mientras usas otras apps, dale a **"BOTÓN FLOTANTE"**.

¡Y ya está! No tiene más pérdida. Si sale un recuadro amarillo, no te asustes, ya lo hemos arreglado para que quepa todo bien.

---
*Desarrollado con ❤️ por PGM y PEDROAI.*


