import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/property.dart';
import '../../data/models/search_filter.dart';
import '../../data/models/price_history.dart';
import '../../data/repositories/property_repository.dart';

// Events
abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class PropertySearchRequested extends PropertyEvent {
  final SearchFilter filter;

  const PropertySearchRequested(this.filter);

  @override
  List<Object?> get props => [filter];
}

class PropertyLoadMoreRequested extends PropertyEvent {}

class PropertyDetailRequested extends PropertyEvent {
  final String propertyId;

  const PropertyDetailRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class PropertyFilterChanged extends PropertyEvent {
  final SearchFilter filter;

  const PropertyFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class PropertyFilterCleared extends PropertyEvent {}

// States
abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoadingMore extends PropertyState {
  final List<Property> properties;
  final SearchFilter filter;

  const PropertyLoadingMore({
    required this.properties,
    required this.filter,
  });

  @override
  List<Object?> get props => [properties, filter];
}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final SearchFilter filter;
  final bool hasMore;

  const PropertyLoaded({
    required this.properties,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.filter,
    required this.hasMore,
  });

  @override
  List<Object?> get props =>
      [properties, totalElements, totalPages, currentPage, filter, hasMore];
}

class PropertyDetailLoaded extends PropertyState {
  final Property property;
  final List<PriceHistory> priceHistory;
  final bool isFavorite;

  const PropertyDetailLoaded({
    required this.property,
    required this.priceHistory,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [property, priceHistory, isFavorite];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository _propertyRepository;

  PropertyBloc({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(PropertyInitial()) {
    on<PropertySearchRequested>(_onSearchRequested);
    on<PropertyLoadMoreRequested>(_onLoadMoreRequested);
    on<PropertyDetailRequested>(_onDetailRequested);
    on<PropertyFilterChanged>(_onFilterChanged);
    on<PropertyFilterCleared>(_onFilterCleared);
  }

  Future<void> _onSearchRequested(
    PropertySearchRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());

    try {
      final result = await _propertyRepository.searchProperties(event.filter);

      emit(PropertyLoaded(
        properties: result.properties,
        totalElements: result.totalElements,
        totalPages: result.totalPages,
        currentPage: result.currentPage,
        filter: event.filter,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(PropertyError('Error al buscar propiedades: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreRequested(
    PropertyLoadMoreRequested event,
    Emitter<PropertyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PropertyLoaded || !currentState.hasMore) return;

    emit(PropertyLoadingMore(
      properties: currentState.properties,
      filter: currentState.filter,
    ));

    try {
      final newFilter = currentState.filter.copyWith(
        page: currentState.currentPage + 1,
      );
      final result = await _propertyRepository.searchProperties(newFilter);

      emit(PropertyLoaded(
        properties: [...currentState.properties, ...result.properties],
        totalElements: result.totalElements,
        totalPages: result.totalPages,
        currentPage: result.currentPage,
        filter: newFilter,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(PropertyLoaded(
        properties: currentState.properties,
        totalElements: currentState.totalElements,
        totalPages: currentState.totalPages,
        currentPage: currentState.currentPage,
        filter: currentState.filter,
        hasMore: currentState.hasMore,
      ));
    }
  }

  Future<void> _onDetailRequested(
    PropertyDetailRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());

    try {
      final property = await _propertyRepository.getProperty(event.propertyId);
      final priceHistory =
          await _propertyRepository.getPriceHistory(event.propertyId);

      emit(PropertyDetailLoaded(
        property: property,
        priceHistory: priceHistory,
        isFavorite: false,
      ));
    } catch (e) {
      emit(PropertyError('Error al cargar la propiedad: ${e.toString()}'));
    }
  }

  Future<void> _onFilterChanged(
    PropertyFilterChanged event,
    Emitter<PropertyState> emit,
  ) async {
    add(PropertySearchRequested(event.filter.copyWith(page: 0)));
  }

  Future<void> _onFilterCleared(
    PropertyFilterCleared event,
    Emitter<PropertyState> emit,
  ) async {
    add(const PropertySearchRequested(SearchFilter()));
  }
}
