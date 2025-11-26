import 'package:equatable/equatable.dart';

class Shop extends Equatable{
  final String? id;
  final String shopName;
  final String shopPhoto;
  final String shopAddress;
  final String shopPhone;

  const Shop({
    this.id,
    required this.shopName,
    required this.shopPhoto,
    required this.shopAddress,
    required this.shopPhone
});

  Shop copyWith({
    String? id,
    String? shopName,
    String? shopPhoto,
    String? shopAddress,
    String? shopPhone,
}) {
    return Shop(
        shopName: shopName ?? this.shopName,
        shopPhoto: shopPhoto ?? this.shopPhoto,
        shopAddress: shopAddress ?? this.shopAddress,
        shopPhone: shopPhone ?? this.shopPhone,
    );
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toString(),
      shopName: json['shopName'] as String? ?? '',
      shopPhoto: json['shopPhoto'] as String? ?? '',
      shopAddress: json['shopAddress'] as String? ?? '',
      shopPhone: json['shopPhone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'shopName' : shopName,
      'shopPhoto' : shopPhoto,
      'shopAddress' : shopAddress,
      'shopPhone' : shopPhone
    };
  }

  @override
  List<Object?> get props => [id, shopName, shopPhoto, shopAddress, shopPhone];
}