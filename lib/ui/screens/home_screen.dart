import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/property/property_bloc.dart';
import '../../data/models/property.dart';
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

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  OperationType? _selectedOperation;
  String? _selectedCity;

  void _navigateToSearch() {
    final params = <String, String>{};
    if (_selectedOperation != null) {
      params['operation'] = _selectedOperation == OperationType.venta ? 'VENTA' : 'ALQUILER';
    }
    if (_selectedCity != null) {
      params['city'] = _selectedCity!;
    }

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    context.go('/search${query.isNotEmpty ? '?$query' : ''}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real State Investing'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated && authState.isDemoMode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: const Text('DEMO'),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
    final hasFilters = _selectedOperation != null || _selectedCity != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de operación',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              avatar: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Comprar'),
              selected: _selectedOperation == OperationType.venta,
              onSelected: (selected) {
                setState(() {
                  _selectedOperation = selected ? OperationType.venta : null;
                });
              },
            ),
            FilterChip(
              avatar: const Icon(Icons.key_outlined, size: 18),
              label: const Text('Alquilar'),
              selected: _selectedOperation == OperationType.alquiler,
              onSelected: (selected) {
                setState(() {
                  _selectedOperation = selected ? OperationType.alquiler : null;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Ciudad',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              avatar: const Icon(Icons.location_city, size: 18),
              label: const Text('Madrid'),
              selected: _selectedCity == 'Madrid',
              onSelected: (selected) {
                setState(() {
                  _selectedCity = selected ? 'Madrid' : null;
                });
              },
            ),
            FilterChip(
              avatar: const Icon(Icons.location_city, size: 18),
              label: const Text('Barcelona'),
              selected: _selectedCity == 'Barcelona',
              onSelected: (selected) {
                setState(() {
                  _selectedCity = selected ? 'Barcelona' : null;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _navigateToSearch,
            icon: const Icon(Icons.search),
            label: Text(hasFilters ? 'Buscar con filtros' : 'Ver todos'),
          ),
        ),
      ],
    );
  }
}
