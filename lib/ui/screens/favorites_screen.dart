import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/favorite/favorite_bloc.dart';
import '../../data/repositories/favorite_repository.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteBloc(
        favoriteRepository: context.read<FavoriteRepository>(),
      )..add(FavoritesLoadRequested()),
      child: const FavoritesScreenContent(),
    );
  }
}

class FavoritesScreenContent extends StatelessWidget {
  const FavoritesScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FavoriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = state is FavoriteLoaded
              ? state.favorites
              : state is FavoriteOperationSuccess
                  ? state.favorites
                  : [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes favoritos guardados'),
                  const SizedBox(height: 8),
                  const Text(
                    'Guarda los inmuebles que te interesen\npara revisarlos más tarde',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar inmuebles'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavoriteBloc>().add(FavoritesLoadRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final property = favorite.property;

                if (property == null) {
                  return const SizedBox.shrink();
                }

                return Dismissible(
                  key: Key(favorite.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar de favoritos'),
                        content: const Text(
                          '¿Estás seguro de que quieres eliminar este inmueble de tus favoritos?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    context.read<FavoriteBloc>().add(
                          FavoriteRemoveRequested(favorite.propertyId),
                        );
                  },
                  child: PropertyCard(
                    property: property,
                    onTap: () {
                      context.go('/property/${property.id}');
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        context.read<FavoriteBloc>().add(
                              FavoriteRemoveRequested(favorite.propertyId),
                            );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
