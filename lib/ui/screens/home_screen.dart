import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/property/property_bloc.dart';
import '../../config/location_constants.dart';
import '../../data/models/property.dart';
import '../../data/repositories/property_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyBloc(
        propertyRepository: context.read<PropertyRepository>(),
      ),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  // Filtros
  String? _postalCode;
  String? _selectedProvince;
  String? _selectedCity;
  OperationType? _selectedOperation;
  PropertyType? _selectedPropertyType;
  int? _minRooms;
  int? _minBathrooms;
  double? _minPrice;
  double? _maxPrice;
  double? _minArea;
  double? _maxArea;

  final _postalCodeController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();

  @override
  void dispose() {
    _postalCodeController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  void _search() {
    // Navegar a búsqueda con los filtros
    final params = <String, String>{};
    if (_postalCode != null) params['postalCode'] = _postalCode!;
    if (_selectedProvince != null) params['province'] = _selectedProvince!;
    if (_selectedCity != null) params['city'] = _selectedCity!;
    if (_selectedOperation != null) {
      params['operation'] = _selectedOperation == OperationType.venta ? 'VENTA' : 'ALQUILER';
    }
    if (_selectedPropertyType != null) {
      params['propertyType'] = _selectedPropertyType!.name.toUpperCase();
    }
    if (_minRooms != null) params['minRooms'] = _minRooms.toString();
    if (_minBathrooms != null) params['minBathrooms'] = _minBathrooms.toString();
    if (_minPrice != null) params['minPrice'] = _minPrice!.toStringAsFixed(0);
    if (_maxPrice != null) params['maxPrice'] = _maxPrice!.toStringAsFixed(0);
    if (_minArea != null) params['minArea'] = _minArea!.toStringAsFixed(0);
    if (_maxArea != null) params['maxArea'] = _maxArea!.toStringAsFixed(0);

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    context.go('/search${query.isNotEmpty ? '?$query' : ''}');
  }

  void _clearFilters() {
    setState(() {
      _postalCode = null;
      _selectedProvince = null;
      _selectedCity = null;
      _selectedOperation = null;
      _selectedPropertyType = null;
      _minRooms = null;
      _minBathrooms = null;
      _minPrice = null;
      _maxPrice = null;
      _minArea = null;
      _maxArea = null;
      _postalCodeController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minAreaController.clear();
      _maxAreaController.clear();
    });
  }

  bool get _hasFilters =>
      _postalCode != null ||
      _selectedProvince != null ||
      _selectedCity != null ||
      _selectedOperation != null ||
      _selectedPropertyType != null ||
      _minRooms != null ||
      _minBathrooms != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _minArea != null ||
      _maxArea != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real State Investing'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated && authState.isDemoMode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: const Text('DEMO'),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Buscar inmuebles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rellena los filtros para encontrar tu inmueble ideal',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),

            // Sección: Ubicación
            _buildSectionTitle('Ubicación'),
            const SizedBox(height: 12),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Código postal',
                hintText: 'Ej: 28001',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _postalCode = value.isEmpty ? null : value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Provincia',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas las provincias')),
                ...LocationConstants.provinces.map((province) =>
                  DropdownMenuItem(value: province, child: Text(province)),
                ),
              ],
              onChanged: (value) => setState(() {
                _selectedProvince = value;
                _selectedCity = null; // Reset city when province changes
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ciudad / Municipio',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...LocationConstants.getCitiesForProvince(_selectedProvince).map((city) =>
                  DropdownMenuItem(value: city, child: Text(city)),
                ),
              ],
              onChanged: _selectedProvince == null
                  ? null
                  : (value) => setState(() => _selectedCity = value),
            ),
            const SizedBox(height: 24),

            // Sección: Tipo de operación
            _buildSectionTitle('Tipo de operación'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.all_inclusive, size: 18),
                  label: const Text('Todas'),
                  selected: _selectedOperation == null,
                  onSelected: (_) => setState(() => _selectedOperation = null),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Comprar'),
                  selected: _selectedOperation == OperationType.venta,
                  onSelected: (_) => setState(() => _selectedOperation = OperationType.venta),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.key_outlined, size: 18),
                  label: const Text('Alquilar'),
                  selected: _selectedOperation == OperationType.alquiler,
                  onSelected: (_) => setState(() => _selectedOperation = OperationType.alquiler),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección: Tipo de inmueble
            _buildSectionTitle('Tipo de inmueble'),
            const SizedBox(height: 12),
            DropdownButtonFormField<PropertyType>(
              value: _selectedPropertyType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos los tipos')),
                DropdownMenuItem(value: PropertyType.piso, child: Text('Piso')),
                DropdownMenuItem(value: PropertyType.casa, child: Text('Casa')),
                DropdownMenuItem(value: PropertyType.chalet, child: Text('Chalet')),
                DropdownMenuItem(value: PropertyType.atico, child: Text('Ático')),
                DropdownMenuItem(value: PropertyType.estudio, child: Text('Estudio')),
                DropdownMenuItem(value: PropertyType.duplex, child: Text('Dúplex')),
                DropdownMenuItem(value: PropertyType.loft, child: Text('Loft')),
              ],
              onChanged: (value) => setState(() => _selectedPropertyType = value),
            ),
            const SizedBox(height: 24),

            // Sección: Precio
            _buildSectionTitle('Precio'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Mínimo',
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minPrice = double.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Máximo',
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxPrice = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección: Habitaciones
            _buildSectionTitle('Habitaciones'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _minRooms == null,
                  onSelected: (_) => setState(() => _minRooms = null),
                ),
                ...List.generate(5, (index) {
                  final rooms = index + 1;
                  return ChoiceChip(
                    label: Text('$rooms+'),
                    selected: _minRooms == rooms,
                    onSelected: (_) => setState(() => _minRooms = rooms),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Sección: Baños
            _buildSectionTitle('Baños'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _minBathrooms == null,
                  onSelected: (_) => setState(() => _minBathrooms = null),
                ),
                ...List.generate(4, (index) {
                  final bathrooms = index + 1;
                  return ChoiceChip(
                    label: Text('$bathrooms+'),
                    selected: _minBathrooms == bathrooms,
                    onSelected: (_) => setState(() => _minBathrooms = bathrooms),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Sección: Superficie
            _buildSectionTitle('Superficie'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Mínimo',
                      suffixText: 'm²',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minArea = double.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxAreaController,
                    decoration: const InputDecoration(
                      labelText: 'Máximo',
                      suffixText: 'm²',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxArea = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                if (_hasFilters)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar'),
                    ),
                  ),
                if (_hasFilters) const SizedBox(width: 16),
                Expanded(
                  flex: _hasFilters ? 2 : 1,
                  child: FilledButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar inmuebles'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
