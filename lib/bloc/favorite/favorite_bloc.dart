import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/favorite.dart';
import '../../data/repositories/favorite_repository.dart';

// Events
abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoriteEvent {}

class FavoriteAddRequested extends FavoriteEvent {
  final String propertyId;
  final String? notes;

  const FavoriteAddRequested({required this.propertyId, this.notes});

  @override
  List<Object?> get props => [propertyId, notes];
}

class FavoriteRemoveRequested extends FavoriteEvent {
  final String propertyId;

  const FavoriteRemoveRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class FavoriteCheckRequested extends FavoriteEvent {
  final String propertyId;

  const FavoriteCheckRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

// States
abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Favorite> favorites;
  final Set<String> favoritePropertyIds;

  const FavoriteLoaded({
    required this.favorites,
    required this.favoritePropertyIds,
  });

  bool isFavorite(String propertyId) => favoritePropertyIds.contains(propertyId);

  @override
  List<Object?> get props => [favorites, favoritePropertyIds];
}

class FavoriteOperationSuccess extends FavoriteState {
  final String message;
  final List<Favorite> favorites;
  final Set<String> favoritePropertyIds;

  const FavoriteOperationSuccess({
    required this.message,
    required this.favorites,
    required this.favoritePropertyIds,
  });

  bool isFavorite(String propertyId) => favoritePropertyIds.contains(propertyId);

  @override
  List<Object?> get props => [message, favorites, favoritePropertyIds];
}

class FavoriteError extends FavoriteState {
  final String message;
  final List<Favorite>? favorites;

  const FavoriteError(this.message, {this.favorites});

  @override
  List<Object?> get props => [message, favorites];
}

// Bloc
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favoriteRepository;
  List<Favorite> _favorites = [];
  Set<String> _favoritePropertyIds = {};

  FavoriteBloc({required FavoriteRepository favoriteRepository})
      : _favoriteRepository = favoriteRepository,
        super(FavoriteInitial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<FavoriteAddRequested>(_onAddRequested);
    on<FavoriteRemoveRequested>(_onRemoveRequested);
    on<FavoriteCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());

    try {
      _favorites = await _favoriteRepository.getFavorites();
      _favoritePropertyIds = _favorites.map((f) => f.propertyId).toSet();
      emit(FavoriteLoaded(
        favorites: _favorites,
        favoritePropertyIds: _favoritePropertyIds,
      ));
    } catch (e) {
      emit(FavoriteError('Error al cargar favoritos: ${e.toString()}'));
    }
  }

  Future<void> _onAddRequested(
    FavoriteAddRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final favorite = await _favoriteRepository.addFavorite(
        event.propertyId,
        notes: event.notes,
      );
      _favorites = [favorite, ..._favorites];
      _favoritePropertyIds = _favorites.map((f) => f.propertyId).toSet();
      emit(FavoriteOperationSuccess(
        message: 'Añadido a favoritos',
        favorites: _favorites,
        favoritePropertyIds: _favoritePropertyIds,
      ));
    } catch (e) {
      emit(FavoriteError(
        'Error al añadir favorito: ${e.toString()}',
        favorites: _favorites,
      ));
    }
  }

  Future<void> _onRemoveRequested(
    FavoriteRemoveRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _favoriteRepository.removeFavorite(event.propertyId);
      _favorites =
          _favorites.where((f) => f.propertyId != event.propertyId).toList();
      _favoritePropertyIds = _favorites.map((f) => f.propertyId).toSet();
      emit(FavoriteOperationSuccess(
        message: 'Eliminado de favoritos',
        favorites: _favorites,
        favoritePropertyIds: _favoritePropertyIds,
      ));
    } catch (e) {
      emit(FavoriteError(
        'Error al eliminar favorito: ${e.toString()}',
        favorites: _favorites,
      ));
    }
  }

  Future<void> _onCheckRequested(
    FavoriteCheckRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    // Already handled by _favoritePropertyIds set
    emit(FavoriteLoaded(
      favorites: _favorites,
      favoritePropertyIds: _favoritePropertyIds,
    ));
  }
}
