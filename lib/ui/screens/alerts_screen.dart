import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../data/models/alert.dart';
import '../../data/models/property.dart';
import '../../data/repositories/alert_repository.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlertBloc(
        alertRepository: context.read<AlertRepository>(),
      )..add(const AlertsLoadRequested()),
      child: const AlertsScreenContent(),
    );
  }
}

class AlertsScreenContent extends StatelessWidget {
  const AlertsScreenContent({super.key});

  void _showCreateAlertDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<AlertBloc>(),
        child: const CreateAlertSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alertas'),
      ),
      body: BlocConsumer<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state is AlertOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AlertError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Alert> alerts = [];
          if (state is AlertLoaded) {
            alerts = state.alerts;
          } else if (state is AlertOperationSuccess) {
            alerts = state.alerts;
          } else if (state is AlertError && state.alerts != null) {
            alerts = state.alerts!;
          }

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes alertas configuradas'),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una alerta para recibir notificaciones\nde nuevos inmuebles',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showCreateAlertDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear alerta'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(
                alert: alert,
                onToggle: (isActive) {
                  context.read<AlertBloc>().add(
                        AlertToggleRequested(
                          id: alert.id!,
                          isActive: isActive,
                        ),
                      );
                },
                onDelete: () {
                  context.read<AlertBloc>().add(
                        AlertDeleteRequested(alert.id!),
                      );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAlertDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.name ?? 'Alerta sin nombre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  onChanged: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar alerta'),
                        content: const Text(
                          '¿Estás seguro de que quieres eliminar esta alerta?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAlertSheet extends StatefulWidget {
  const CreateAlertSheet({super.key});

  @override
  State<CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<CreateAlertSheet> {
  final _nameController = TextEditingController();
  String? _selectedCity;
  OperationType? _operationType;
  double? _minPrice;
  double? _maxPrice;
  int? _minRooms;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createAlert() {
    final alert = Alert(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      city: _selectedCity,
      operationType: _operationType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRooms: _minRooms,
    );

    context.read<AlertBloc>().add(AlertCreateRequested(alert));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                'Nueva Alerta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la alerta (opcional)',
                  hintText: 'Ej: Pisos en Madrid Centro',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                items: const [
                  DropdownMenuItem(value: 'Madrid', child: Text('Madrid')),
                  DropdownMenuItem(value: 'Barcelona', child: Text('Barcelona')),
                  DropdownMenuItem(value: 'Valencia', child: Text('Valencia')),
                  DropdownMenuItem(value: 'Sevilla', child: Text('Sevilla')),
                ],
                onChanged: (value) => setState(() => _selectedCity = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<OperationType>(
                value: _operationType,
                decoration: const InputDecoration(labelText: 'Tipo de operación'),
                items: const [
                  DropdownMenuItem(
                    value: OperationType.venta,
                    child: Text('Comprar'),
                  ),
                  DropdownMenuItem(
                    value: OperationType.alquiler,
                    child: Text('Alquilar'),
                  ),
                ],
                onChanged: (value) => setState(() => _operationType = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Precio mínimo',
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
                      decoration: const InputDecoration(
                        labelText: 'Precio máximo',
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
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _minRooms,
                decoration: const InputDecoration(labelText: 'Habitaciones mínimas'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}+'),
                  ),
                ),
                onChanged: (value) => setState(() => _minRooms = value),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _createAlert,
                child: const Text('Crear alerta'),
              ),
            ],
          ),
        );
      },
    );
  }
}
