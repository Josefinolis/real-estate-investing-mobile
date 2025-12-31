import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/property/property_bloc.dart';
import '../../bloc/favorite/favorite_bloc.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../widgets/price_chart.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PropertyBloc(
            propertyRepository: context.read<PropertyRepository>(),
          )..add(PropertyDetailRequested(propertyId)),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            favoriteRepository: context.read<FavoriteRepository>(),
          )..add(FavoritesLoadRequested()),
        ),
      ],
      child: const PropertyDetailContent(),
    );
  }
}

class PropertyDetailContent extends StatelessWidget {
  const PropertyDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state is PropertyLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PropertyError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        if (state is PropertyDetailLoaded) {
          final property = state.property;
          final priceHistory = state.priceHistory;

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: property.imageUrls?.isNotEmpty == true
                        ? Image.network(
                            property.imageUrls!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.home, size: 64),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, size: 64),
                          ),
                  ),
                  actions: [
                    BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favoriteState) {
                        bool isFavorite = false;
                        if (favoriteState is FavoriteLoaded) {
                          isFavorite = favoriteState.isFavorite(property.id);
                        } else if (favoriteState is FavoriteOperationSuccess) {
                          isFavorite = favoriteState.isFavorite(property.id);
                        }

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoriteBloc>().add(
                                    FavoriteRemoveRequested(property.id),
                                  );
                            } else {
                              context.read<FavoriteBloc>().add(
                                    FavoriteAddRequested(propertyId: property.id),
                                  );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(property.sourceDisplayName),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            ),
                            const SizedBox(width: 8),
                            if (property.operationType != null)
                              Chip(
                                label: Text(
                                  property.operationType!.name == 'VENTA'
                                      ? 'Venta'
                                      : 'Alquiler',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          property.formattedPrice,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        if (property.pricePerM2 != null)
                          Text(
                            '${property.pricePerM2!.toStringAsFixed(0)} €/m²',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        const SizedBox(height: 16),
                        if (property.title != null)
                          Text(
                            property.title!,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        const SizedBox(height: 8),
                        if (property.address != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(child: Text(property.address!)),
                            ],
                          ),
                        const SizedBox(height: 24),
                        _buildFeatures(context, property),
                        const SizedBox(height: 24),
                        if (property.description != null) ...[
                          Text(
                            'Descripción',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(property.description!),
                          const SizedBox(height: 24),
                        ],
                        if (priceHistory.length > 1) ...[
                          Text(
                            'Historial de precios',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PriceChart(priceHistory: priceHistory),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () async {
                    if (property.url != null) {
                      final uri = Uri.parse(property.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text('Ver en ${property.sourceDisplayName}'),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Error')),
        );
      },
    );
  }

  Widget _buildFeatures(BuildContext context, dynamic property) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (property.rooms != null)
          _FeatureItem(
            icon: Icons.bed_outlined,
            value: '${property.rooms}',
            label: 'Habitaciones',
          ),
        if (property.bathrooms != null)
          _FeatureItem(
            icon: Icons.bathtub_outlined,
            value: '${property.bathrooms}',
            label: 'Baños',
          ),
        if (property.areaM2 != null)
          _FeatureItem(
            icon: Icons.square_foot,
            value: '${property.areaM2!.toStringAsFixed(0)}',
            label: 'm²',
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FeatureItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
