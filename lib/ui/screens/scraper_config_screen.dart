import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/scraper/scraper_bloc.dart';
import '../../config/location_constants.dart';
import '../../data/models/scraper_config.dart';
import '../../data/repositories/scraper_repository.dart';

class ScraperConfigScreen extends StatelessWidget {
  const ScraperConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScraperBloc(
        scraperRepository: context.read<ScraperRepository>(),
      )..add(ScraperConfigLoadRequested()),
      child: const ScraperConfigScreenContent(),
    );
  }
}

class ScraperConfigScreenContent extends StatefulWidget {
  const ScraperConfigScreenContent({super.key});

  @override
  State<ScraperConfigScreenContent> createState() =>
      _ScraperConfigScreenContentState();
}

class _ScraperConfigScreenContentState
    extends State<ScraperConfigScreenContent> {
  late bool _enabled;
  late List<String> _selectedCities;
  late List<String> _selectedOperationTypes;
  late List<String> _selectedSources;
  late String _cronExpression;
  double? _minPrice;
  double? _maxPrice;
  int? _minRooms;
  int? _maxRooms;
  double? _minArea;
  double? _maxArea;
  List<String>? _selectedPropertyTypes;

  bool _initialized = false;

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  void _initializeFromConfig(ScraperConfig config) {
    if (_initialized) return;
    _initialized = true;

    _enabled = config.enabled;
    _selectedCities = List.from(config.cities);
    _selectedOperationTypes = List.from(config.operationTypes);
    _selectedSources = List.from(config.sources);
    _cronExpression = config.cronExpression;
    _minPrice = config.minPrice;
    _maxPrice = config.maxPrice;
    _minRooms = config.minRooms;
    _maxRooms = config.maxRooms;
    _minArea = config.minArea;
    _maxArea = config.maxArea;
    _selectedPropertyTypes = config.propertyTypes;

    _minPriceController.text = _minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = _maxPrice?.toStringAsFixed(0) ?? '';
    _minAreaController.text = _minArea?.toStringAsFixed(0) ?? '';
    _maxAreaController.text = _maxArea?.toStringAsFixed(0) ?? '';
  }

  void _saveConfig() {
    final update = ScraperConfigUpdate(
      cities: _selectedCities,
      operationTypes: _selectedOperationTypes,
      propertyTypes: _selectedPropertyTypes,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRooms: _minRooms,
      maxRooms: _maxRooms,
      minArea: _minArea,
      maxArea: _maxArea,
      enabled: _enabled,
      cronExpression: _cronExpression,
      sources: _selectedSources,
    );

    context.read<ScraperBloc>().add(ScraperConfigUpdateRequested(update));
  }

  void _triggerRun() {
    context.read<ScraperBloc>().add(ScraperTriggerRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion del Scraper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: BlocConsumer<ScraperBloc, ScraperState>(
        listener: (context, state) {
          if (state is ScraperOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ScraperError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScraperLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScraperConfigLoaded) {
            _initializeFromConfig(state.config);
            return _buildForm(
              context,
              state.availableCities,
              state.propertyTypes,
              state.frequencies,
            );
          }

          if (state is ScraperError && !_initialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<ScraperBloc>().add(ScraperConfigLoadRequested());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Keep showing form even during loading (for updates)
          if (_initialized) {
            return Stack(
              children: [
                _buildForm(context, [], [], []),
                if (state is ScraperLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<String> availableCities,
    List<String> propertyTypes,
    List<Map<String, String>> frequencies,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado del scraper
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _enabled ? Icons.play_circle : Icons.pause_circle,
                    color: _enabled ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _enabled ? 'Scraper activo' : 'Scraper pausado',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _enabled
                              ? 'Se ejecutara automaticamente'
                              : 'No se ejecutara hasta que lo actives',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ejecutar ahora
          FilledButton.icon(
            onPressed: _triggerRun,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Ejecutar ahora'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 24),

          // Frecuencia
          _buildSectionTitle(context, 'Frecuencia'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _cronExpression,
            decoration: const InputDecoration(
              labelText: 'Intervalo de ejecucion',
              prefixIcon: Icon(Icons.schedule),
            ),
            items: frequencies.isNotEmpty
                ? frequencies.map((freq) {
                    return DropdownMenuItem(
                      value: freq['cron'],
                      child: Text(freq['label'] ?? freq['cron']!),
                    );
                  }).toList()
                : [
                    DropdownMenuItem(
                      value: _cronExpression,
                      child: Text(_getCronLabel(_cronExpression)),
                    ),
                  ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _cronExpression = value);
              }
            },
          ),
          const SizedBox(height: 24),

          // Fuentes
          _buildSectionTitle(context, 'Fuentes'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSourceChip('IDEALISTA', 'Idealista'),
              _buildSourceChip('PISOSCOM', 'Pisos.com'),
              _buildSourceChip('FOTOCASA', 'Fotocasa'),
            ],
          ),
          const SizedBox(height: 24),

          // Ciudades / Municipios
          _buildSectionTitle(context, 'Ciudades / Municipios'),
          const SizedBox(height: 12),
          _buildCitiesSelector(availableCities),
          const SizedBox(height: 24),

          // Tipo de operación
          _buildSectionTitle(context, 'Tipo de operacion'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildOperationChip('VENTA', 'Comprar'),
              _buildOperationChip('ALQUILER', 'Alquilar'),
            ],
          ),
          const SizedBox(height: 24),

          // Filtros de precio
          _buildSectionTitle(context, 'Filtros de precio'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio minimo',
                    suffixText: 'E',
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
                    labelText: 'Precio maximo',
                    suffixText: 'E',
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

          // Filtros de habitaciones
          _buildSectionTitle(context, 'Habitaciones'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _minRooms,
                  decoration: const InputDecoration(
                    labelText: 'Minimo',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin minimo')),
                    ...List.generate(6, (i) => i + 1).map((r) =>
                        DropdownMenuItem(value: r, child: Text('$r+'))),
                  ],
                  onChanged: (value) => setState(() => _minRooms = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _maxRooms,
                  decoration: const InputDecoration(
                    labelText: 'Maximo',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin maximo')),
                    ...List.generate(6, (i) => i + 1).map((r) =>
                        DropdownMenuItem(value: r, child: Text('$r'))),
                  ],
                  onChanged: (value) => setState(() => _maxRooms = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtros de área
          _buildSectionTitle(context, 'Superficie'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Minimo',
                    suffixText: 'm2',
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
                    labelText: 'Maximo',
                    suffixText: 'm2',
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

          // Guardar
          FilledButton.icon(
            onPressed: _saveConfig,
            icon: const Icon(Icons.save),
            label: const Text('Guardar configuracion'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSourceChip(String value, String label) {
    final isSelected = _selectedSources.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedSources.add(value);
          } else {
            _selectedSources.remove(value);
          }
        });
      },
    );
  }

  Widget _buildOperationChip(String value, String label) {
    final isSelected = _selectedOperationTypes.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedOperationTypes.add(value);
          } else if (_selectedOperationTypes.length > 1) {
            _selectedOperationTypes.remove(value);
          }
        });
      },
    );
  }

  Widget _buildCitiesSelector(List<String> availableCities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedCities.length} ciudades/municipios seleccionados',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: LocationConstants.provinces.length,
            itemBuilder: (context, index) {
              final province = LocationConstants.provinces[index];
              final cities = LocationConstants.getCitiesForProvince(province);
              final selectedInProvince = cities.where((c) => _selectedCities.contains(c)).length;
              final allSelected = selectedInProvince == cities.length;
              final someSelected = selectedInProvince > 0 && !allSelected;

              return ExpansionTile(
                title: Text(province),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedInProvince > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectedInProvince',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    Checkbox(
                      value: allSelected ? true : (someSelected ? null : false),
                      tristate: true,
                      onChanged: (value) {
                        setState(() {
                          if (allSelected) {
                            _selectedCities.removeWhere((c) => cities.contains(c));
                          } else {
                            for (final city in cities) {
                              if (!_selectedCities.contains(city)) {
                                _selectedCities.add(city);
                              }
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
                children: cities.map((city) {
                  final isSelected = _selectedCities.contains(city);
                  return CheckboxListTile(
                    title: Text(city),
                    value: isSelected,
                    dense: true,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedCities.add(city);
                        } else {
                          _selectedCities.remove(city);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _selectedCities = List.from(LocationConstants.allCities)),
              child: const Text('Seleccionar todas'),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedCities.clear()),
              child: const Text('Deseleccionar todas'),
            ),
          ],
        ),
      ],
    );
  }

  String _getCronLabel(String cron) {
    switch (cron) {
      case '0 */15 * * * *':
        return 'Cada 15 minutos';
      case '0 */30 * * * *':
        return 'Cada 30 minutos';
      case '0 0 * * * *':
        return 'Cada hora';
      case '0 0 */2 * * *':
        return 'Cada 2 horas';
      case '0 0 */6 * * *':
        return 'Cada 6 horas';
      case '0 0 */12 * * *':
        return 'Cada 12 horas';
      case '0 0 8 * * *':
        return 'Una vez al dia';
      default:
        return cron;
    }
  }
}
