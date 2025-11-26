import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/shop.dart';
part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  static const String _shopKey = 'shop_data';

  ShopCubit() : super(ShopInitial());

  // Load data toko dari SharedPreferences
  Future<void> loadShop() async {
    emit(ShopLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final shopJson = prefs.getString(_shopKey);

      if (shopJson != null && shopJson.isNotEmpty) {
        final shopMap = json.decode(shopJson) as Map<String, dynamic>;
        final shop = Shop.fromJson(shopMap);
        emit(ShopLoaded(shop));
      } else {
        emit(ShopEmpty());
      }
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  // Save atau Update shop
  Future<void> saveShop(Shop shop) async {
    emit(ShopLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final shopJson = json.encode(shop.toJson());
      await prefs.setString(_shopKey, shopJson);

      emit(ShopSaved(shop));

      // Setelah save, load ulang data
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ShopLoaded(shop));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  // Clear shop data (optional - untuk delete)
  Future<void> clearShop() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_shopKey);
      emit(ShopEmpty());
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }
}