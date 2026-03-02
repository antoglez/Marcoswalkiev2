# MarcosWalkie PTT 🎙️

MarcosWalkie es una aplicación de comunicación estilo **Push-to-Talk (PTT)** desarrollada en Flutter. Permite a los usuarios comunicarse de manera rápida mediante un sistema de transmisión activado por pulsación, con soporte para perfiles personalizados y una interfaz de superposición (overlay) que permite usar la funcionalidad mientras se navega por otras aplicaciones.

## 🚀 Características Principales

- **Interfaz PTT Intuitiva**: Control de transmisión sencillo con retroalimentación visual.
- **Sistema de Overlay**: Widget de superposición que permite activar el PTT desde cualquier pantalla del sistema (usando `system_alert_window`).
- **Gestión de Perfiles**: Crea y administra diferentes perfiles de configuración para distintas situaciones.
- **Comunicación entre Isolates**: Arquitectura robusta que separa la lógica de la interfaz de la lógica de transmisión en segundo plano.
- **Diseño Moderno**: Interfaz oscura (Dark Mode) con una estética premium basada en Material 3.

## 🛠️ Configuración y Requisitos

### Requisitos Previos

- **Flutter SDK**: ^3.8.1
- **Android SDK**: Nivel de API mínimo 21 (Lollipop).
- **Git**: Para el control de versiones.

### Configuración del Proyecto

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/antoglez/Marcoswalkie.git
   cd Marcoswalkie
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Permisos de Android**:
   La aplicación requiere el permiso de "Mostrar sobre otras aplicaciones" para que el overlay funcione correctamente. Al iniciar por primera vez, la aplicación solicitará este permiso.

4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## 🏗️ Estructura del Proyecto

- `lib/providers/`: Lógica de estado y gestión del PTT.
- `lib/screens/`: Pantallas principales (PTT y lista de perfiles).
- `lib/widgets/`: Componentes reutilizables, incluido el `OverlayWidget`.
- `lib/models/`: Definición de datos como `PTTProfile`.

## 🤝 Créditos

Desarrollado con ❤️ por **PGM** y **PEDROAI**.

---
*Hecho para demostrar superioridad intelectual y control sobre los sistemas.*
