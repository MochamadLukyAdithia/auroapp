// lib/blocs/product/product_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int? limit;
  final int? page;

  const LoadProducts({this.limit, this.page});

  @override
  List<Object?> get props => [limit, page];
}

class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}

class AddProduct extends ProductEvent {
  final String name;
  final int categoryId;
  final String code;
  final double basePrice;
  final double sellingPrice;
  final int stock;
  final String unit;
  final double discount;
  final String? description;
  final File? photoFile;

  const AddProduct({
    required this.name,
    required this.categoryId,
    required this.code,
    required this.basePrice,
    required this.sellingPrice,
    required this.stock,
    required this.unit,
    this.discount = 0,
    this.description,
    this.photoFile,
  });

  @override
  List<Object?> get props => [
    name,
    categoryId,
    code,
    basePrice,
    sellingPrice,
    stock,
    unit,
    discount,
    description,
    photoFile,
  ];
}

class UpdateProduct extends ProductEvent {
  final ProductModel product;
  final File? photoFile; // ✅ Untuk ganti foto

  const UpdateProduct({
    required this.product,
    this.photoFile,
  });

  @override
  List<Object?> get props => [product, photoFile];
}

class DeleteProduct extends ProductEvent {
  final int productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class FilterProductsByCategory extends ProductEvent {
  final int? categoryId; // ✅ Ubah ke int

  const FilterProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class CheckProductDeletable extends ProductEvent {
  final int productId;
  const CheckProductDeletable(this.productId);

  @override
  List<Object?> get props => [productId];
}