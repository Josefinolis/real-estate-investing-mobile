import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/alert.dart';
import '../../data/repositories/alert_repository.dart';

// Events
abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class AlertsLoadRequested extends AlertEvent {
  final bool activeOnly;

  const AlertsLoadRequested({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

class AlertCreateRequested extends AlertEvent {
  final Alert alert;

  const AlertCreateRequested(this.alert);

  @override
  List<Object?> get props => [alert];
}

class AlertUpdateRequested extends AlertEvent {
  final String id;
  final Alert alert;

  const AlertUpdateRequested({required this.id, required this.alert});

  @override
  List<Object?> get props => [id, alert];
}

class AlertDeleteRequested extends AlertEvent {
  final String id;

  const AlertDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class AlertToggleRequested extends AlertEvent {
  final String id;
  final bool isActive;

  const AlertToggleRequested({required this.id, required this.isActive});

  @override
  List<Object?> get props => [id, isActive];
}

// States
abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<Alert> alerts;

  const AlertLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class AlertOperationSuccess extends AlertState {
  final String message;
  final List<Alert> alerts;

  const AlertOperationSuccess({required this.message, required this.alerts});

  @override
  List<Object?> get props => [message, alerts];
}

class AlertError extends AlertState {
  final String message;
  final List<Alert>? alerts;

  const AlertError(this.message, {this.alerts});

  @override
  List<Object?> get props => [message, alerts];
}

// Bloc
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository _alertRepository;
  List<Alert> _alerts = [];

  AlertBloc({required AlertRepository alertRepository})
      : _alertRepository = alertRepository,
        super(AlertInitial()) {
    on<AlertsLoadRequested>(_onLoadRequested);
    on<AlertCreateRequested>(_onCreateRequested);
    on<AlertUpdateRequested>(_onUpdateRequested);
    on<AlertDeleteRequested>(_onDeleteRequested);
    on<AlertToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
    AlertsLoadRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    try {
      _alerts = await _alertRepository.getAlerts(activeOnly: event.activeOnly);
      emit(AlertLoaded(_alerts));
    } catch (e) {
      emit(AlertError('Error al cargar las alertas: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    AlertCreateRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    try {
      final newAlert = await _alertRepository.createAlert(event.alert);
      _alerts = [newAlert, ..._alerts];
      emit(AlertOperationSuccess(
        message: 'Alerta creada correctamente',
        alerts: _alerts,
      ));
    } catch (e) {
      emit(AlertError(
        'Error al crear la alerta: ${e.toString()}',
        alerts: _alerts,
      ));
    }
  }

  Future<void> _onUpdateRequested(
    AlertUpdateRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    try {
      final updatedAlert =
          await _alertRepository.updateAlert(event.id, event.alert);
      _alerts = _alerts.map((a) => a.id == event.id ? updatedAlert : a).toList();
      emit(AlertOperationSuccess(
        message: 'Alerta actualizada correctamente',
        alerts: _alerts,
      ));
    } catch (e) {
      emit(AlertError(
        'Error al actualizar la alerta: ${e.toString()}',
        alerts: _alerts,
      ));
    }
  }

  Future<void> _onDeleteRequested(
    AlertDeleteRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    try {
      await _alertRepository.deleteAlert(event.id);
      _alerts = _alerts.where((a) => a.id != event.id).toList();
      emit(AlertOperationSuccess(
        message: 'Alerta eliminada correctamente',
        alerts: _alerts,
      ));
    } catch (e) {
      emit(AlertError(
        'Error al eliminar la alerta: ${e.toString()}',
        alerts: _alerts,
      ));
    }
  }

  Future<void> _onToggleRequested(
    AlertToggleRequested event,
    Emitter<AlertState> emit,
  ) async {
    final alertIndex = _alerts.indexWhere((a) => a.id == event.id);
    if (alertIndex == -1) return;

    final alert = _alerts[alertIndex];
    final updatedAlert = alert.copyWith(isActive: event.isActive);

    try {
      await _alertRepository.updateAlert(event.id, updatedAlert);
      _alerts[alertIndex] = updatedAlert;
      emit(AlertLoaded(List.from(_alerts)));
    } catch (e) {
      emit(AlertError(
        'Error al actualizar la alerta: ${e.toString()}',
        alerts: _alerts,
      ));
    }
  }
}
