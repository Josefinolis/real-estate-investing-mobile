# Real State Investing

Aplicación móvil para buscar y rastrear inmuebles en portales españoles (Idealista, Fotocasa, Pisos.com).

## Descargar

**[Descargar APK](https://github.com/Josefinolis/real-estate-investing-mobile/releases/latest)**

### Instalación
1. Descarga el APK en tu Android
2. Activa "Instalar desde fuentes desconocidas" si te lo pide
3. Abre el archivo para instalar

## Funcionalidades

- Búsqueda de inmuebles con filtros (ciudad, precio, habitaciones, etc.)
- Alertas personalizadas para nuevos inmuebles
- Guardar favoritos
- Historial de precios
- Notificaciones push

## Modo Demo

Si Firebase no está configurado, la app ofrece un **modo demo** para explorar la interfaz sin necesidad de crear cuenta.

## Desarrollo

### Requisitos
- Flutter 3.16+
- Dart 3.2+

### Ejecutar
```bash
flutter pub get
flutter run
```

### Compilar APK
```bash
flutter build apk --release
```

## Backend

- **API:** http://195.20.235.94/realstate/api
- **Repo:** [real-estate-investing-backend](https://github.com/Josefinolis/real-estate-investing-backend)

## Releases

Los APKs se generan automáticamente al crear un tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```
