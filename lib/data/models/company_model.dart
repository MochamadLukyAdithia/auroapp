// company_model.dart
import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final int? id;
  final String name;
  final String? logo;
  final String address;
  final String phone;

  const Company({
    this.id,
    required this.name,
    this.logo,
    required this.address,
    required this.phone,
  });

  Company copyWith({
    int? id,
    String? name,
    String? logo,
    String? address,
    String? phone,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  // Parse dari response Laravel showProfile()
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['company_id'],
      name: json['store_name'],
      logo: json['store_profile'],
      address: json['store_address'],
      phone: json['store_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'address': address,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, name, logo, address, phone];
}