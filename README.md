# Real State Investing - App Móvil

Aplicación Flutter multiplataforma para rastrear inmuebles en Idealista, Fotocasa y Pisos.com.

## Tecnologías

- **Flutter** 3.16+
- **Dart** 3.2+
- **flutter_bloc** 8.1.3 (State Management)
- **go_router** 13.0.0 (Navegación)
- **Firebase Auth** 4.16.0 (Autenticación)
- **Firebase Messaging** 14.7.0 (Push Notifications)
- **Dio** 5.4.0 (HTTP Client)
- **fl_chart** 0.66.0 (Gráficos)

## Arquitectura

La app sigue el patrón **BLoC (Business Logic Component)** con repositorios.

```
lib/
├── main.dart                    # Punto de entrada
├── config/
│   ├── app_config.dart          # Configuración (URLs, constantes)
│   └── routes.dart              # Definición de rutas (go_router)
├── data/
│   ├── models/                  # Modelos de datos
│   │   ├── property.dart
│   │   ├── alert.dart
│   │   ├── favorite.dart
│   │   ├── price_history.dart
│   │   ├── search_filter.dart
│   │   └── user.dart
│   ├── repositories/            # Abstracción de datos
│   │   ├── auth_repository.dart
│   │   ├── property_repository.dart
│   │   ├── alert_repository.dart
│   │   └── favorite_repository.dart
│   └── services/                # Servicios externos
│       ├── api_service.dart     # Cliente HTTP
│       └── notification_service.dart
├── bloc/                        # Lógica de negocio
│   ├── auth/
│   │   └── auth_bloc.dart
│   ├── property/
│   │   └── property_bloc.dart
│   ├── alert/
│   │   └── alert_bloc.dart
│   └── favorite/
│       └── favorite_bloc.dart
└── ui/
    ├── screens/                 # Pantallas
    │   ├── login_screen.dart
    │   ├── home_screen.dart
    │   ├── search_screen.dart
    │   ├── property_detail_screen.dart
    │   ├── alerts_screen.dart
    │   └── favorites_screen.dart
    └── widgets/                 # Componentes reutilizables
        ├── property_card.dart
        ├── filter_panel.dart
        └── price_chart.dart
```

## Pantallas

### Login (`/login`)
- Autenticación con email/password
- Registro de nuevos usuarios
- Integración con Firebase Auth

### Home (`/`)
- Vista de últimos inmuebles
- Filtros rápidos (Comprar/Alquilar, ciudades)
- Acceso a búsqueda completa

### Búsqueda (`/search`)
- Listado de propiedades con scroll infinito
- Panel de filtros avanzados:
  - Ciudad
  - Tipo de operación (Venta/Alquiler)
  - Tipo de propiedad
  - Rango de precio
  - Número de habitaciones
  - Superficie

### Detalle de propiedad (`/property/:id`)
- Galería de imágenes
- Información completa del inmueble
- Gráfico de historial de precios
- Botón de favorito
- Enlace al portal original

### Alertas (`/alerts`)
- Listado de alertas configuradas
- Crear nueva alerta con filtros
- Activar/desactivar alertas
- Eliminar alertas

### Favoritos (`/favorites`)
- Listado de propiedades guardadas
- Deslizar para eliminar
- Acceso rápido al detalle

## Modelos de Datos

### Property
```dart
class Property {
  final String id;
  final String externalId;
  final PropertySource source;  // idealista, fotocasa, pisoscom
  final String? title;
  final double? price;
  final OperationType? operationType;  // venta, alquiler
  final PropertyType? propertyType;
  final int? rooms;
  final int? bathrooms;
  final double? areaM2;
  final String? city;
  final List<String>? imageUrls;
  final String? url;
  // ...
}
```

### SearchFilter
```dart
class SearchFilter {
  final String? city;
  final OperationType? operationType;
  final PropertyType? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final int? maxRooms;
  final double? minArea;
  final double? maxArea;
  final int page;
  final int size;
}
```

### Alert
```dart
class Alert {
  final String? id;
  final String? name;
  final OperationType? operationType;
  final PropertyType? propertyType;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final bool isActive;
}
```

## BLoCs

### AuthBloc
```dart
// Events
AuthCheckRequested()      // Verificar sesión actual
AuthSignInRequested()     // Iniciar sesión
AuthSignUpRequested()     // Registrarse
AuthSignOutRequested()    // Cerrar sesión

// States
AuthInitial()
AuthLoading()
AuthAuthenticated(user)
AuthUnauthenticated()
AuthError(message)
```

### PropertyBloc
```dart
// Events
PropertySearchRequested(filter)    // Buscar propiedades
PropertyLoadMoreRequested()        // Cargar más (paginación)
PropertyDetailRequested(id)        // Ver detalle
PropertyFilterChanged(filter)      // Cambiar filtros
PropertyFilterCleared()            // Limpiar filtros

// States
PropertyInitial()
PropertyLoading()
PropertyLoadingMore(properties, filter)
PropertyLoaded(properties, totalElements, hasMore, ...)
PropertyDetailLoaded(property, priceHistory, isFavorite)
PropertyError(message)
```

### AlertBloc
```dart
// Events
AlertsLoadRequested()              // Cargar alertas
AlertCreateRequested(alert)        // Crear alerta
AlertUpdateRequested(id, alert)    // Actualizar alerta
AlertDeleteRequested(id)           // Eliminar alerta
AlertToggleRequested(id, isActive) // Activar/desactivar

// States
AlertInitial()
AlertLoading()
AlertLoaded(alerts)
AlertOperationSuccess(message, alerts)
AlertError(message)
```

### FavoriteBloc
```dart
// Events
FavoritesLoadRequested()           // Cargar favoritos
FavoriteAddRequested(propertyId)   // Añadir favorito
FavoriteRemoveRequested(propertyId)// Eliminar favorito

// States
FavoriteInitial()
FavoriteLoading()
FavoriteLoaded(favorites, favoritePropertyIds)
FavoriteOperationSuccess(message, favorites)
FavoriteError(message)
```

## Descargar APK

La app está disponible para descargar desde GitHub Releases:

**[Descargar última versión](https://github.com/Josefinolis/real-estate-investing-mobile/releases/latest)**

### Instalación
1. Descarga `app-debug.apk` o `app-release.apk`
2. En tu Android, activa "Instalar desde fuentes desconocidas"
3. Abre el archivo APK para instalar

## Backend

La app se conecta al servidor de producción:
- **API URL:** `http://195.20.235.94:8081/api`
- **Repositorio:** [real-estate-investing-backend](https://github.com/Josefinolis/real-estate-investing-backend)
- **Infrastructure:** https://github.com/Josefinolis/documentation

## Configuración

### app_config.dart
```dart
class AppConfig {
  // Servidor de producción (por defecto)
  static const String apiBaseUrl = 'http://195.20.235.94:8081/api';

  // Desarrollo - Emulador Android
  // static const String apiBaseUrl = 'http://10.0.2.2:8080/api';

  // Desarrollo - Simulador iOS
  // static const String apiBaseUrl = 'http://localhost:8080/api';

  static const int defaultPageSize = 20;
  static const Duration connectionTimeout = Duration(seconds: 30);
}
```

### Firebase

1. Crear proyecto en Firebase Console
2. Añadir app Android con package name: `com.realstate.real_state_investing_mobile`
3. Descargar `google-services.json` → `android/app/`
4. (iOS) Descargar `GoogleService-Info.plist` → `ios/Runner/`

## Ejecución

### Desarrollo
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run

# Ejecutar con hot reload
flutter run --hot
```

### Build

#### Android
```bash
# APK debug
flutter build apk --debug

# APK release
flutter build apk --release

# App Bundle (para Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Abrir en Xcode
open ios/Runner.xcworkspace

# Build desde terminal
flutter build ios --release
```

### Tests
```bash
# Unit tests
flutter test

# Tests con coverage
flutter test --coverage
```

## Dependencias

```yaml
dependencies:
  flutter_bloc: ^8.1.3      # State management
  equatable: ^2.0.5         # Comparación de objetos
  go_router: ^13.0.0        # Navegación declarativa
  dio: ^5.4.0               # HTTP client
  firebase_core: ^2.24.0    # Firebase base
  firebase_auth: ^4.16.0    # Autenticación
  firebase_messaging: ^14.7.0 # Push notifications
  shared_preferences: ^2.2.2  # Almacenamiento local
  fl_chart: ^0.66.0         # Gráficos de precios
  cached_network_image: ^3.3.1 # Caché de imágenes
  shimmer: ^3.0.0           # Loading effects
  intl: ^0.18.1             # Formateo de fechas/números
  url_launcher: ^6.2.2      # Abrir URLs externas

dev_dependencies:
  flutter_lints: ^3.0.1     # Reglas de lint
  bloc_test: ^9.1.5         # Testing de BLoCs
  mocktail: ^1.0.1          # Mocking
```

## Flujo de Autenticación

```
┌─────────────┐
│   App Init  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ AuthCheckRequested │
└──────┬──────────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
┌──────┐ ┌───────────────┐
│Login │ │ Authenticated │
└──┬───┘ └───────┬───────┘
   │             │
   ▼             ▼
┌──────────────────────────┐
│    Main App (HomeScreen) │
└──────────────────────────┘
```

## Notificaciones Push

El servicio de notificaciones maneja:
- Solicitud de permisos
- Obtención del FCM token
- Recepción en foreground/background
- Navegación al tap

```dart
// Tipos de notificación
{
  "type": "new_property",    // Nueva propiedad que coincide con alerta
  "propertyId": "uuid",
  "alertName": "Mi alerta"
}

{
  "type": "price_change",    // Cambio de precio en favorito
  "propertyId": "uuid",
  "oldPrice": "200000",
  "newPrice": "195000"
}
```

## Releases y CI/CD

El proyecto usa GitHub Actions para builds automáticos:

### Crear nueva release
```bash
# Crear y subir tag
git tag -a v1.0.1 -m "Descripción de la versión"
git push origin v1.0.1
```

También puedes disparar manualmente desde GitHub Actions > "Build and Release APK" > "Run workflow".

### Workflow
El workflow `.github/workflows/release.yml`:
1. Compila APKs (debug y release)
2. Crea una GitHub Release
3. Adjunta los APKs para descargar

## Mejoras Futuras

- [ ] Mapas con ubicación de propiedades
- [ ] Comparador de propiedades
- [ ] Calculadora de hipoteca
- [ ] Compartir propiedades
- [ ] Modo offline con caché local
- [ ] Dark mode toggle
- [ ] Múltiples idiomas
- [ ] Widget de Android/iOS
