import 'package:flutter/material.dart';
import '../../data/models/property.dart';
import '../../data/models/search_filter.dart';

class FilterPanel extends StatefulWidget {
  final SearchFilter initialFilter;
  final ValueChanged<SearchFilter> onApply;

  const FilterPanel({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late String? _selectedCity;
  late String? _postalCode;
  late OperationType? _operationType;
  late PropertyType? _propertyType;
  late double? _minPrice;
  late double? _maxPrice;
  late int? _minRooms;
  late int? _maxRooms;
  late int? _minBathrooms;
  late double? _minArea;
  late double? _maxArea;

  final _postalCodeController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialFilter.city;
    _postalCode = widget.initialFilter.postalCode;
    _operationType = widget.initialFilter.operationType;
    _propertyType = widget.initialFilter.propertyType;
    _minPrice = widget.initialFilter.minPrice;
    _maxPrice = widget.initialFilter.maxPrice;
    _minRooms = widget.initialFilter.minRooms;
    _maxRooms = widget.initialFilter.maxRooms;
    _minBathrooms = widget.initialFilter.minBathrooms;
    _minArea = widget.initialFilter.minArea;
    _maxArea = widget.initialFilter.maxArea;

    if (_postalCode != null) {
      _postalCodeController.text = _postalCode!;
    }
    if (_minPrice != null) {
      _minPriceController.text = _minPrice!.toStringAsFixed(0);
    }
    if (_maxPrice != null) {
      _maxPriceController.text = _maxPrice!.toStringAsFixed(0);
    }
    if (_minArea != null) {
      _minAreaController.text = _minArea!.toStringAsFixed(0);
    }
    if (_maxArea != null) {
      _maxAreaController.text = _maxArea!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _postalCodeController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _postalCode = null;
      _operationType = null;
      _propertyType = null;
      _minPrice = null;
      _maxPrice = null;
      _minRooms = null;
      _maxRooms = null;
      _minBathrooms = null;
      _minArea = null;
      _maxArea = null;
      _postalCodeController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minAreaController.clear();
      _maxAreaController.clear();
    });
  }

  void _applyFilters() {
    final filter = SearchFilter(
      city: _selectedCity,
      postalCode: _postalCode,
      operationType: _operationType,
      propertyType: _propertyType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRooms: _minRooms,
      maxRooms: _maxRooms,
      minBathrooms: _minBathrooms,
      minArea: _minArea,
      maxArea: _maxArea,
    );
    widget.onApply(filter);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionTitle('Ubicación'),
                  TextField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código postal',
                      hintText: 'Ej: 28001',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _postalCode = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'Madrid', child: Text('Madrid')),
                      DropdownMenuItem(
                          value: 'Barcelona', child: Text('Barcelona')),
                      DropdownMenuItem(
                          value: 'Valencia', child: Text('Valencia')),
                      DropdownMenuItem(value: 'Sevilla', child: Text('Sevilla')),
                      DropdownMenuItem(value: 'Málaga', child: Text('Málaga')),
                      DropdownMenuItem(value: 'Zaragoza', child: Text('Zaragoza')),
                      DropdownMenuItem(value: 'Bilbao', child: Text('Bilbao')),
                    ],
                    onChanged: (value) => setState(() => _selectedCity = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de operación'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: _operationType == null,
                        onSelected: (_) =>
                            setState(() => _operationType = null),
                      ),
                      ChoiceChip(
                        label: const Text('Comprar'),
                        selected: _operationType == OperationType.venta,
                        onSelected: (_) =>
                            setState(() => _operationType = OperationType.venta),
                      ),
                      ChoiceChip(
                        label: const Text('Alquilar'),
                        selected: _operationType == OperationType.alquiler,
                        onSelected: (_) => setState(
                            () => _operationType = OperationType.alquiler),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de inmueble'),
                  DropdownButtonFormField<PropertyType>(
                    value: _propertyType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(
                          value: PropertyType.piso, child: Text('Piso')),
                      DropdownMenuItem(
                          value: PropertyType.casa, child: Text('Casa')),
                      DropdownMenuItem(
                          value: PropertyType.chalet, child: Text('Chalet')),
                      DropdownMenuItem(
                          value: PropertyType.atico, child: Text('Ático')),
                      DropdownMenuItem(
                          value: PropertyType.estudio, child: Text('Estudio')),
                    ],
                    onChanged: (value) =>
                        setState(() => _propertyType = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Precio'),
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
                            _minPrice = double.tryParse(value);
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
                            _maxPrice = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Habitaciones'),
                  Wrap(
                    spacing: 8,
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
                  _buildSectionTitle('Baños'),
                  Wrap(
                    spacing: 8,
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
                  _buildSectionTitle('Superficie'),
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
                            _minArea = double.tryParse(value);
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
                            _maxArea = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
