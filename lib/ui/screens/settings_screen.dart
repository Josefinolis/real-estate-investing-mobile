import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Scraper'),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuracion del scraper'),
            subtitle: const Text('Ciudades, filtros y frecuencia'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/scraper'),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text('Monitor de ejecuciones'),
            subtitle: const Text('Historial y estado del scraper'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/scraper/monitor'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.3.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
