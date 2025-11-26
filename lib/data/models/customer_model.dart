// // models/customer.dart
// import 'package:equatable/equatable.dart';
//
// class Customer extends Equatable {
//   final String? id;
//   final String name;
//   final String? address;
//   final String phone;
//   final String? email;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   const Customer({
//     this.id,
//     required this.name,
//     this.address,
//     required this.phone,
//     this.email,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   // ✅ copyWith untuk update
//   Customer copyWith({
//     String? id,
//     String? name,
//     String? address,
//     String? phone,
//     String? email,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return Customer(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       address: address ?? this.address,
//       phone: phone ?? this.phone,
//       email: email ?? this.email,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   // ✅ fromJson - sesuai dengan response PHP backend
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       id: json['id']?.toString(),
//       name: json['customer_name'] as String, // ⬅️ Sesuai backend
//       address: json['customer_address'] as String?,
//       phone: json['customer_phone'] as String,
//       email: json['customer_email'] as String?,
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//     );
//   }
//
//   // ✅ toJson - untuk kirim ke API
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'customer_name': name, // ⬅️ Sesuai backend
//       if (address != null) 'customer_address': address,
//       'customer_phone': phone,
//       if (email != null) 'customer_email': email,
//     };
//   }
//
//   // ✅ toCreateJson - untuk request create (tanpa id)
//   Map<String, dynamic> toCreateJson() {
//     return {
//       'customer_name': name,
//       if (address != null) 'customer_address': address,
//       'customer_phone': phone,
//       if (email != null) 'customer_email': email,
//     };
//   }
//
//   // ✅ toUpdateJson - untuk request update
//   Map<String, dynamic> toUpdateJson() {
//     return {
//       'customer_name': name,
//       'customer_address': address,
//       'customer_phone': phone,
//       'customer_email': email,
//     };
//   }
//
//   @override
//   List<Object?> get props => [id, name, address, phone, email, createdAt, updatedAt];
//
//   @override
//   String toString() {
//     return 'Customer(id: $id, name: $name, phone: $phone, email: $email)';
//   }
// }


// models/customer.dart
import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String? id;
  final String name;
  final String? address;
  final String phone;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.address,
    required this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ copyWith untuk update
  Customer copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ fromJson - sesuai dengan response PHP backend
  factory Customer.fromJson(Map<String, dynamic> json) {
    try {
      return Customer(
        id: json['id']?.toString(),
        name: json['customer_name'] as String? ?? json['name'] as String? ?? '',
        address: json['customer_address'] as String? ?? json['address'] as String?,
        phone: json['customer_phone'] as String? ?? json['phone'] as String? ?? '',
        email: json['customer_email'] as String? ?? json['email'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      print('Error parsing Customer from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  // ✅ toJson - untuk kirim ke API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_name': name, // ⬅️ Sesuai backend
      if (address != null) 'customer_address': address,
      'customer_phone': phone,
      if (email != null) 'customer_email': email,
    };
  }

  // ✅ toCreateJson - untuk request create (tanpa id)
  Map<String, dynamic> toCreateJson() {
    return {
      'customer_name': name,
      if (address != null) 'customer_address': address,
      'customer_phone': phone,
      if (email != null) 'customer_email': email,
    };
  }

  // ✅ toUpdateJson - untuk request update
  Map<String, dynamic> toUpdateJson() {
    return {
      'customer_name': name,
      'customer_address': address,
      'customer_phone': phone,
      'customer_email': email,
    };
  }

  @override
  List<Object?> get props => [id, name, address, phone, email, createdAt, updatedAt];

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, email: $email)';
  }
}