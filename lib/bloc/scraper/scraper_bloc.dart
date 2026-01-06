import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/scraper_config.dart';
import '../../data/models/scraper_run.dart';
import '../../data/repositories/scraper_repository.dart';

// Events
abstract class ScraperEvent extends Equatable {
  const ScraperEvent();

  @override
  List<Object?> get props => [];
}

class ScraperStatusRequested extends ScraperEvent {}

class ScraperConfigLoadRequested extends ScraperEvent {}

class ScraperConfigUpdateRequested extends ScraperEvent {
  final ScraperConfigUpdate config;

  const ScraperConfigUpdateRequested(this.config);

  @override
  List<Object?> get props => [config];
}

class ScraperHistoryLoadRequested extends ScraperEvent {
  final int page;
  final bool refresh;

  const ScraperHistoryLoadRequested({this.page = 0, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class ScraperTriggerRequested extends ScraperEvent {}

class ScraperOptionsLoadRequested extends ScraperEvent {}

// States
abstract class ScraperState extends Equatable {
  const ScraperState();

  @override
  List<Object?> get props => [];
}

class ScraperInitial extends ScraperState {}

class ScraperLoading extends ScraperState {}

class ScraperStatusLoaded extends ScraperState {
  final bool isRunning;
  final ScraperRun? lastRun;
  final ScraperConfig? config;

  const ScraperStatusLoaded({
    required this.isRunning,
    this.lastRun,
    this.config,
  });

  @override
  List<Object?> get props => [isRunning, lastRun, config];
}

class ScraperConfigLoaded extends ScraperState {
  final ScraperConfig config;
  final List<String> availableCities;
  final List<String> propertyTypes;
  final List<Map<String, String>> frequencies;

  const ScraperConfigLoaded({
    required this.config,
    required this.availableCities,
    required this.propertyTypes,
    required this.frequencies,
  });

  @override
  List<Object?> get props => [config, availableCities, propertyTypes, frequencies];
}

class ScraperHistoryLoaded extends ScraperState {
  final List<ScraperRun> runs;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasMore;

  const ScraperHistoryLoaded({
    required this.runs,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [runs, totalElements, currentPage, hasMore];
}

class ScraperOperationSuccess extends ScraperState {
  final String message;

  const ScraperOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ScraperError extends ScraperState {
  final String message;

  const ScraperError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ScraperBloc extends Bloc<ScraperEvent, ScraperState> {
  final ScraperRepository _scraperRepository;
  List<ScraperRun> _runs = [];
  ScraperConfig? _config;
  List<String> _availableCities = [];
  List<String> _propertyTypes = [];
  List<Map<String, String>> _frequencies = [];

  ScraperBloc({required ScraperRepository scraperRepository})
      : _scraperRepository = scraperRepository,
        super(ScraperInitial()) {
    on<ScraperStatusRequested>(_onStatusRequested);
    on<ScraperConfigLoadRequested>(_onConfigLoadRequested);
    on<ScraperConfigUpdateRequested>(_onConfigUpdateRequested);
    on<ScraperHistoryLoadRequested>(_onHistoryLoadRequested);
    on<ScraperTriggerRequested>(_onTriggerRequested);
    on<ScraperOptionsLoadRequested>(_onOptionsLoadRequested);
  }

  Future<void> _onStatusRequested(
    ScraperStatusRequested event,
    Emitter<ScraperState> emit,
  ) async {
    emit(ScraperLoading());

    try {
      final status = await _scraperRepository.getStatus();
      emit(ScraperStatusLoaded(
        isRunning: status.isRunning,
        lastRun: status.lastRun,
      ));
    } catch (e) {
      emit(ScraperError('Error al obtener estado: ${e.toString()}'));
    }
  }

  Future<void> _onConfigLoadRequested(
    ScraperConfigLoadRequested event,
    Emitter<ScraperState> emit,
  ) async {
    emit(ScraperLoading());

    try {
      // Load config and options in parallel
      final results = await Future.wait([
        _scraperRepository.getConfig(),
        _scraperRepository.getAvailableCities(),
        _scraperRepository.getPropertyTypes(),
        _scraperRepository.getFrequencies(),
      ]);

      _config = results[0] as ScraperConfig;
      _availableCities = results[1] as List<String>;
      _propertyTypes = results[2] as List<String>;
      _frequencies = results[3] as List<Map<String, String>>;

      emit(ScraperConfigLoaded(
        config: _config!,
        availableCities: _availableCities,
        propertyTypes: _propertyTypes,
        frequencies: _frequencies,
      ));
    } catch (e) {
      emit(ScraperError('Error al cargar configuracion: ${e.toString()}'));
    }
  }

  Future<void> _onConfigUpdateRequested(
    ScraperConfigUpdateRequested event,
    Emitter<ScraperState> emit,
  ) async {
    emit(ScraperLoading());

    try {
      _config = await _scraperRepository.updateConfig(event.config);
      emit(ScraperConfigLoaded(
        config: _config!,
        availableCities: _availableCities,
        propertyTypes: _propertyTypes,
        frequencies: _frequencies,
      ));
      emit(ScraperOperationSuccess('Configuracion guardada correctamente'));
    } catch (e) {
      emit(ScraperError('Error al guardar configuracion: ${e.toString()}'));
    }
  }

  Future<void> _onHistoryLoadRequested(
    ScraperHistoryLoadRequested event,
    Emitter<ScraperState> emit,
  ) async {
    if (event.refresh) {
      _runs = [];
    }

    if (event.page == 0 && !event.refresh) {
      emit(ScraperLoading());
    }

    try {
      final result = await _scraperRepository.getRunHistory(page: event.page);

      if (event.page == 0 || event.refresh) {
        _runs = result.runs;
      } else {
        _runs = [..._runs, ...result.runs];
      }

      emit(ScraperHistoryLoaded(
        runs: _runs,
        totalElements: result.totalElements,
        totalPages: result.totalPages,
        currentPage: result.currentPage,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(ScraperError('Error al cargar historial: ${e.toString()}'));
    }
  }

  Future<void> _onTriggerRequested(
    ScraperTriggerRequested event,
    Emitter<ScraperState> emit,
  ) async {
    emit(ScraperLoading());

    try {
      final result = await _scraperRepository.triggerRun();
      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '';

      if (success) {
        emit(ScraperOperationSuccess(message));
      } else {
        emit(ScraperError(message));
      }
    } catch (e) {
      emit(ScraperError('Error al iniciar scraper: ${e.toString()}'));
    }
  }

  Future<void> _onOptionsLoadRequested(
    ScraperOptionsLoadRequested event,
    Emitter<ScraperState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _scraperRepository.getAvailableCities(),
        _scraperRepository.getPropertyTypes(),
        _scraperRepository.getFrequencies(),
      ]);

      _availableCities = results[0] as List<String>;
      _propertyTypes = results[1] as List<String>;
      _frequencies = results[2] as List<Map<String, String>>;
    } catch (e) {
      // Silently fail, options will be empty
    }
  }
}
