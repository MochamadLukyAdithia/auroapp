import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String ROLE_OWNER = 'owner';
  static const String ROLE_CASHIER = 'cashier';

  // cek apakah owner atau cashier
  static Future<bool> isOwner() async {
    final role = await getCurrentRole();
    return role == ROLE_OWNER;
  }
  static Future<bool> isCashier() async {
    final role = await getCurrentRole();
    return role == ROLE_CASHIER;
  }

  static Future<String?> getCurrentRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🆕 Baca dari current_user_data (bukan owner_data)
      final currentUserJson = prefs.getString('current_user_data');

      if (currentUserJson == null || currentUserJson.isEmpty) return null;

      final data = jsonDecode(currentUserJson) as Map<String, dynamic>;
      return data['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerJson = prefs.getString('current_user_data');

      if (ownerJson == null || ownerJson.isEmpty) return null;
      return jsonDecode(ownerJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCurrentUserName() async {
    final user = await getCurrentUser();
    return user?['full_name'] as String?; // ✅ Sama untuk owner & cashier
  }

  static Future<String?> getCurrentUserPhone() async {
    final user = await getCurrentUser();
    return user?['phone_number'] as String?; // ✅ Sama untuk owner & cashier
  }

  static Future<String?> getCurrentUserAddress() async {
    final user = await getCurrentUser();
    return user?['user_address'] as String?; // ✅ Sama untuk owner & cashier
  }

  // static Future<int?> getCurrentCompanyId() async {
  //   final user = await getCurrentUser();
  //   return user?['company_id'] as int?; // 🆕 Helper baru
  // }

  static Future<String?> getCurrentUserEmail() async {
    final user = await getCurrentUser();
    return user?['email'] as String?;
  }

  static String getRoleDisplayName(String? role) {
    switch (role) {
      case ROLE_OWNER:
        return 'Owner';
      case ROLE_CASHIER:
        return 'Kasir';
      default:
        return 'Pengguna';
    }
  }
  /// Get display name role user saat ini
  static Future<String> getCurrentRoleDisplayName() async {
    final role = await getCurrentRole();
    return getRoleDisplayName(role);
  }
}