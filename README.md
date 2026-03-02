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
4. **Perfiles (Donde se configuran los PRIVADOS/INTENTS):**
   - La app usa "perfiles" para saber a qué app de Walkie Talkie debe enviar la señal. **Aquí es donde incluyes los "Intents" (comandos internos)** que quieres llamar para cada aplicación.
   - Dale al icono del **engranaje** (⚙️) para crear o editar uno.
   - Solo tienes que poner el nombre y las "acciones" (los Intents) que te diga el manual de tu otra app (ej: Zello).
5. **A hablar:**
   - En la pantalla principal, selecciona el perfil que quieras.
   - Mantén pulsado el **círculo grande central** para hablar, o usa tu botón USB.
   - **Botón Flotante (Para usar con otras apps):**
     - La primera vez que le des a "BOTÓN FLOTANTE", el móvil te llevará a una pantalla de ajustes para pedirte **permisos de superposición**. 
     - Busca **MarcosWalkie** en la lista y activa el interruptor para darle permiso.
     - Vuelve atrás a la aplicación y dale otra vez al botón.
     - ¡Magia! Aparecerá una burbuja que **puedes mover con el dedo** por toda la pantalla y usarla mientras estás en Zello u otras aplicaciones.

¡Y ya está! No tiene más pérdida. Si sale un recuadro amarillo, no te asustes, ya lo hemos arreglado para que quepa todo bien.

---
*Desarrollado con ❤️ por PGM y PEDROAI.*


