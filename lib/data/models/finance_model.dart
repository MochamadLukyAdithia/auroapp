import 'package:equatable/equatable.dart';

enum FinanceType {
  income,
  outcome,
}

extension FinanceTypeExtension on FinanceType {
  String get displayName {
    switch (this) {
      case FinanceType.income:
        return 'Pemasukan';
      case FinanceType.outcome:
        return 'Pengeluaran';
    }
  }

  String get value {
    switch (this) {
      case FinanceType.income:
        return 'income';
      case FinanceType.outcome:
        return 'outcome';
    }
  }
}

class Finance extends Equatable {
  final int? id;
  final String name;
  final double amount; // ✅ Sudah double
  final FinanceType type;
  final DateTime date;
  final String? description;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Finance({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Finance copyWith({
    int? id,
    String? name,
    double? amount,
    FinanceType? type,
    DateTime? date,
    String? description,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Finance(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'financials_name': name,
      'nominal': amount,
      'financials_type': type.value,
      'financials_date': formatDate(date), // ✅ Pakai method static
      if (description != null) 'financials_description': description,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // ✅ From JSON
  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: json['id'],
      name: json['financials_name'] ?? '',
      amount: _parseAmount(json['nominal']),
      type: _parseType(json['financials_type']),
      date: _parseDate(json['financials_date']),
      description: json['financials_description'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // ✅ Helper: Parse amount
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ✅ Helper: Parse type
  static FinanceType _parseType(dynamic value) {
    if (value == 'income') return FinanceType.income;
    if (value == 'outcome') return FinanceType.outcome;
    return FinanceType.outcome;
  }

  // ✅ Helper: Parse date
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // ✅ STATIC METHOD - Format date untuk backend (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    type,
    date,
    description,
    userId,
    createdAt,
    updatedAt,
  ];
}