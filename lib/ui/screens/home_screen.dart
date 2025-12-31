import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/property/property_bloc.dart';
import '../../data/models/search_filter.dart';
import '../../data/repositories/property_repository.dart';
import '../widgets/property_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyBloc(
        propertyRepository: context.read<PropertyRepository>(),
      )..add(const PropertySearchRequested(SearchFilter())),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real State Investing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PropertyBloc>().add(
                const PropertySearchRequested(SearchFilter()),
              );
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre los últimos inmuebles disponibles',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickFilters(context),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos inmuebles',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/search'),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<PropertyBloc, PropertyState>(
              builder: (context, state) {
                if (state is PropertyLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is PropertyError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              context.read<PropertyBloc>().add(
                                    const PropertySearchRequested(SearchFilter()),
                                  );
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is PropertyLoaded) {
                  if (state.properties.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('No hay inmuebles disponibles'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final property = state.properties[index];
                          return PropertyCard(
                            property: property,
                            onTap: () {
                              context.go('/property/${property.id}');
                            },
                          );
                        },
                        childCount: state.properties.length.clamp(0, 10),
                      ),
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickFilterChip(
          label: 'Comprar',
          icon: Icons.shopping_cart_outlined,
          onTap: () => context.go('/search?operation=VENTA'),
        ),
        _QuickFilterChip(
          label: 'Alquilar',
          icon: Icons.key_outlined,
          onTap: () => context.go('/search?operation=ALQUILER'),
        ),
        _QuickFilterChip(
          label: 'Madrid',
          icon: Icons.location_city,
          onTap: () => context.go('/search?city=Madrid'),
        ),
        _QuickFilterChip(
          label: 'Barcelona',
          icon: Icons.location_city,
          onTap: () => context.go('/search?city=Barcelona'),
        ),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
