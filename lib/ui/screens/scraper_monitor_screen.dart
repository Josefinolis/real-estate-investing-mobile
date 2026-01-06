import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/scraper/scraper_bloc.dart';
import '../../data/models/scraper_run.dart';
import '../../data/repositories/scraper_repository.dart';

class ScraperMonitorScreen extends StatelessWidget {
  const ScraperMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScraperBloc(
        scraperRepository: context.read<ScraperRepository>(),
      )..add(const ScraperHistoryLoadRequested()),
      child: const ScraperMonitorScreenContent(),
    );
  }
}

class ScraperMonitorScreenContent extends StatefulWidget {
  const ScraperMonitorScreenContent({super.key});

  @override
  State<ScraperMonitorScreenContent> createState() =>
      _ScraperMonitorScreenContentState();
}

class _ScraperMonitorScreenContentState
    extends State<ScraperMonitorScreenContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 0;

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() {
    final state = context.read<ScraperBloc>().state;
    if (state is ScraperHistoryLoaded && state.hasMore && !_isLoadingMore) {
      _isLoadingMore = true;
      _currentPage++;
      context
          .read<ScraperBloc>()
          .add(ScraperHistoryLoadRequested(page: _currentPage));
    }
  }

  Future<void> _refresh() async {
    _currentPage = 0;
    _isLoadingMore = false;
    context
        .read<ScraperBloc>()
        .add(const ScraperHistoryLoadRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor del Scraper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocConsumer<ScraperBloc, ScraperState>(
        listener: (context, state) {
          if (state is ScraperHistoryLoaded) {
            _isLoadingMore = false;
          } else if (state is ScraperError) {
            _isLoadingMore = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScraperLoading && _currentPage == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScraperHistoryLoaded) {
            if (state.runs.isEmpty) {
              return _buildEmptyState();
            }
            return _buildRunsList(state);
          }

          if (state is ScraperError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text('No hay ejecuciones registradas'),
          const SizedBox(height: 8),
          Text(
            'Las ejecuciones del scraper apareceran aqui',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRunsList(ScraperHistoryLoaded state) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.runs.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.runs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final run = state.runs[index];
          return _ScraperRunCard(run: run);
        },
      ),
    );
  }
}

class _ScraperRunCard extends StatefulWidget {
  final ScraperRun run;

  const _ScraperRunCard({required this.run});

  @override
  State<_ScraperRunCard> createState() => _ScraperRunCardState();
}

class _ScraperRunCardState extends State<_ScraperRunCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final run = widget.run;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(run.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          run.timeAgo,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          _formatDateTime(run.startedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(run.status),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricChip(
                    Icons.home,
                    '${run.totalPropertiesFound}',
                    'Total',
                  ),
                  _buildMetricChip(
                    Icons.fiber_new,
                    '${run.newProperties}',
                    'Nuevos',
                    Colors.green,
                  ),
                  _buildMetricChip(
                    Icons.update,
                    '${run.updatedProperties}',
                    'Actualizados',
                    Colors.blue,
                  ),
                  _buildMetricChip(
                    Icons.trending_down,
                    '${run.priceChanges}',
                    'Precios',
                    Colors.orange,
                  ),
                ],
              ),
              if (_expanded) ...[
                const Divider(height: 24),
                // Detailed info
                _buildDetailRow('Duracion', run.formattedDuration),
                const SizedBox(height: 8),
                _buildDetailRow('Idealista', '${run.idealistaCount} propiedades'),
                _buildDetailRow('Pisos.com', '${run.pisoscomCount} propiedades'),
                _buildDetailRow('Fotocasa', '${run.fotocasaCount} propiedades'),
                if (run.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline,
                                size: 16, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          run.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
                if (run.filtersUsed != null) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: const Text('Filtros utilizados'),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      _buildFiltersInfo(run.filtersUsed!),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ScraperRunStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case ScraperRunStatus.running:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case ScraperRunStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ScraperRunStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(ScraperRunStatus status) {
    Color color;
    String label;

    switch (status) {
      case ScraperRunStatus.running:
        color = Colors.blue;
        label = 'En ejecucion';
        break;
      case ScraperRunStatus.completed:
        color = Colors.green;
        label = 'Completado';
        break;
      case ScraperRunStatus.failed:
        color = Colors.red;
        label = 'Error';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String value, String label,
      [Color? color]) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildFiltersInfo(Map<String, dynamic> filters) {
    final items = <Widget>[];

    if (filters['cities'] != null) {
      final cities = (filters['cities'] as List).cast<String>();
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                child: Text('Ciudades:', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: Text('${cities.length} ciudades'),
              ),
            ],
          ),
        ),
      );
    }

    if (filters['operationTypes'] != null) {
      final ops = (filters['operationTypes'] as List).join(', ');
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text('Operacion:', style: TextStyle(color: Colors.grey)),
              ),
              Text(ops),
            ],
          ),
        ),
      );
    }

    if (filters['sources'] != null) {
      final sources = (filters['sources'] as List).join(', ');
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text('Fuentes:', style: TextStyle(color: Colors.grey)),
              ),
              Text(sources),
            ],
          ),
        ),
      );
    }

    return Column(children: items);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
