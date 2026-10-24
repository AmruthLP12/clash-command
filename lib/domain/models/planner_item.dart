import 'dart:convert';

import 'upgrade_category.dart';

/// Resource requirement for a planned upgrade.
class PlannerResource {
  const PlannerResource({
    required this.type,
    required this.amount,
  });

  /// Name of the resource (e.g. 'Gold', 'Elixir', 'Dark Elixir', 'Builder Gold', 'Builder Elixir').
  final String type;

  /// Required resource amount.
  final int amount;

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
      };

  factory PlannerResource.fromJson(Map<String, dynamic> json) =>
      PlannerResource(
        type: json['type'] as String? ?? 'Gold',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
      );

  /// Compact human-readable amount string, e.g. "12.5M Gold", "250k Dark Elixir".
  String get formattedAmount {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      final formatted = m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1);
      return '${formatted}M $type';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      final formatted = k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1);
      return '${formatted}k $type';
    }
    return '$amount $type';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannerResource &&
          other.type == type &&
          other.amount == amount);

  @override
  int get hashCode => Object.hash(type, amount);

  @override
  String toString() => 'PlannerResource($type: $amount)';
}

/// Domain model representing a planned future upgrade.
class PlannerItem {
  const PlannerItem({
    required this.id,
    required this.villageId,
    required this.category,
    required this.name,
    this.targetLevel,
    this.priority = 'Medium',
    this.notes,
    this.sortOrder = 0,
    this.status = 'planned',
    this.isNext = false,
    this.durationSeconds,
    this.resources = const [],
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String villageId;
  final UpgradeCategory category;
  final String name;
  final int? targetLevel;
  final String priority; // 'High', 'Medium', 'Low'
  final String? notes;
  final int sortOrder;
  final String status; // 'planned', 'started', 'completed', 'cancelled'
  final bool isNext;
  final int? durationSeconds;
  final List<PlannerResource> resources;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  String get displayNameWithLevel {
    if (targetLevel != null) {
      return '$name · Lv. $targetLevel';
    }
    return name;
  }

  static List<PlannerResource> parseResources(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(PlannerResource.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  static String? encodeResources(List<PlannerResource> list) {
    if (list.isEmpty) return null;
    return jsonEncode(list.map((r) => r.toJson()).toList());
  }

  PlannerItem copyWith({
    String? id,
    String? villageId,
    UpgradeCategory? category,
    String? name,
    int? targetLevel,
    bool clearTargetLevel = false,
    String? priority,
    String? notes,
    bool clearNotes = false,
    int? sortOrder,
    String? status,
    bool? isNext,
    int? durationSeconds,
    bool clearDurationSeconds = false,
    List<PlannerResource>? resources,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return PlannerItem(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      category: category ?? this.category,
      name: name ?? this.name,
      targetLevel:
          clearTargetLevel ? null : (targetLevel ?? this.targetLevel),
      priority: priority ?? this.priority,
      notes: clearNotes ? null : (notes ?? this.notes),
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      isNext: isNext ?? this.isNext,
      durationSeconds: clearDurationSeconds
          ? null
          : (durationSeconds ?? this.durationSeconds),
      resources: resources ?? this.resources,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlannerItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PlannerItem(id: $id, name: $name, targetLevel: $targetLevel, duration: $durationSeconds, resources: ${resources.length})';
}
