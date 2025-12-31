import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/property/property_bloc.dart';
import '../../data/models/property.dart';
import '../../data/models/search_filter.dart';
import '../../data/repositories/property_repository.dart';
import '../widgets/property_card.dart';
import '../widgets/filter_panel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertyBloc(
        propertyRepository: context.read<PropertyRepository>(),
      )..add(const PropertySearchRequested(SearchFilter())),
      child: const SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  const SearchScreenContent({super.key});

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final ScrollController _scrollController = ScrollController();
  SearchFilter _currentFilter = const SearchFilter();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PropertyBloc>().add(PropertyLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterPanel(
        initialFilter: _currentFilter,
        onApply: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          context.read<PropertyBloc>().add(PropertyFilterChanged(filter));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _currentFilter.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterPanel,
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PropertyError) {
            return Center(
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
                            PropertySearchRequested(_currentFilter),
                          );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          List<Property> properties = [];
          bool isLoadingMore = false;
          bool hasMore = false;
          int totalElements = 0;

          if (state is PropertyLoaded) {
            properties = state.properties;
            hasMore = state.hasMore;
            totalElements = state.totalElements;
          } else if (state is PropertyLoadingMore) {
            properties = state.properties;
            isLoadingMore = true;
            hasMore = true;
          }

          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No se encontraron inmuebles'),
                  if (_currentFilter.hasActiveFilters) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = const SearchFilter();
                        });
                        context.read<PropertyBloc>().add(PropertyFilterCleared());
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '$totalElements inmuebles encontrados',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const Spacer(),
                    if (_currentFilter.hasActiveFilters)
                      TextButton.icon(
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpiar'),
                        onPressed: () {
                          setState(() {
                            _currentFilter = const SearchFilter();
                          });
                          context.read<PropertyBloc>().add(PropertyFilterCleared());
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: properties.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= properties.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final property = properties[index];
                    return PropertyCard(
                      property: property,
                      onTap: () {
                        context.go('/property/${property.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
