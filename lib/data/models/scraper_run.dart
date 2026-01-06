import 'package:equatable/equatable.dart';
import 'dart:convert';

enum ScraperRunStatus { running, completed, failed }

class ScraperRun extends Equatable {
  final String id;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final ScraperRunStatus status;
  final int? durationSeconds;
  final int totalPropertiesFound;
  final int newProperties;
  final int updatedProperties;
  final int priceChanges;
  final int idealistaCount;
  final int pisoscomCount;
  final int fotocasaCount;
  final String? errorMessage;
  final String? errorDetails;
  final Map<String, dynamic>? filtersUsed;

  const ScraperRun({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    this.durationSeconds,
    required this.totalPropertiesFound,
    required this.newProperties,
    required this.updatedProperties,
    required this.priceChanges,
    required this.idealistaCount,
    required this.pisoscomCount,
    required this.fotocasaCount,
    this.errorMessage,
    this.errorDetails,
    this.filtersUsed,
  });

  factory ScraperRun.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? filters;
    if (json['filtersUsed'] != null) {
      try {
        if (json['filtersUsed'] is String) {
          filters = jsonDecode(json['filtersUsed'] as String) as Map<String, dynamic>;
        } else if (json['filtersUsed'] is Map) {
          filters = json['filtersUsed'] as Map<String, dynamic>;
        }
      } catch (_) {
        filters = null;
      }
    }

    return ScraperRun(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'] as String)
          : null,
      status: ScraperRunStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => ScraperRunStatus.running,
      ),
      durationSeconds: json['durationSeconds'] as int?,
      totalPropertiesFound: json['totalPropertiesFound'] as int? ?? 0,
      newProperties: json['newProperties'] as int? ?? 0,
      updatedProperties: json['updatedProperties'] as int? ?? 0,
      priceChanges: json['priceChanges'] as int? ?? 0,
      idealistaCount: json['idealistaCount'] as int? ?? 0,
      pisoscomCount: json['pisoscomCount'] as int? ?? 0,
      fotocasaCount: json['fotocasaCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      errorDetails: json['errorDetails'] as String?,
      filtersUsed: filters,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case ScraperRunStatus.running:
        return 'En ejecucion';
      case ScraperRunStatus.completed:
        return 'Completado';
      case ScraperRunStatus.failed:
        return 'Error';
    }
  }

  String get formattedDuration {
    if (durationSeconds == null) return '-';
    if (durationSeconds! < 60) return '${durationSeconds}s';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(startedAt);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  @override
  List<Object?> get props => [id, startedAt, status];
}

class ScraperRunList {
  final List<ScraperRun> runs;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const ScraperRunList({
    required this.runs,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory ScraperRunList.fromJson(Map<String, dynamic> json) {
    return ScraperRunList(
      runs: (json['runs'] as List<dynamic>)
          .map((e) => ScraperRun.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }

  bool get hasMore => currentPage < totalPages - 1;
}

class ScraperStatus {
  final bool isRunning;
  final ScraperRun? lastRun;
  final Map<String, dynamic>? config;

  const ScraperStatus({
    required this.isRunning,
    this.lastRun,
    this.config,
  });

  factory ScraperStatus.fromJson(Map<String, dynamic> json) {
    return ScraperStatus(
      isRunning: json['isRunning'] as bool,
      lastRun: json['lastRun'] != null
          ? ScraperRun.fromJson(json['lastRun'] as Map<String, dynamic>)
          : null,
      config: json['config'] as Map<String, dynamic>?,
    );
  }
}
