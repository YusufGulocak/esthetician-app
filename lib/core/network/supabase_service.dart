import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // Giriş yap
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Kayıt ol
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );
  }

  // Çıkış yap
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Mevcut kullanıcı
  static User? get currentUser => _client.auth.currentUser;

  // Admin mi kontrolü
  static Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final response = await _client
        .from('users')
        .select('role')
        .eq('id', currentUser!.id)
        .single();
    return response['role'] == 'admin';
  }
}