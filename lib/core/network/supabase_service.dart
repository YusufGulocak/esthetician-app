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
  static Future<List<Map<String, dynamic>>> getAppointments() async {
  final response = await _client
      .from('appointments')
      .select('*, services(name, duration_minutes), users(full_name, phone)')
      .order('date', ascending: true)
      .order('time', ascending: true);
  return List<Map<String, dynamic>>.from(response);
}

// Bugünün randevularını getir
static Future<List<Map<String, dynamic>>> getTodayAppointments() async {
  final today = DateTime.now().toIso8601String().split('T')[0];
  final response = await _client
      .from('appointments')
      .select('*, services(name, duration_minutes), users(full_name, phone)')
      .eq('date', today)
      .order('time', ascending: true);
  return List<Map<String, dynamic>>.from(response);
}

// Randevu durumunu güncelle
static Future<void> updateAppointmentStatus(String id, String status) async {
  await _client
      .from('appointments')
      .update({'status': status})
      .eq('id', id);
}

// Tüm hizmetleri getir
static Future<List<Map<String, dynamic>>> getServices() async {
  final response = await _client
      .from('services')
      .select()
      .eq('is_active', true)
      .order('name');
  return List<Map<String, dynamic>>.from(response);
}
// Yeni randevu kaydet
static Future<void> createAppointment({
  required String serviceId,
  required String date,
  required String time,
  required String? notes,
  String? customerName,
  String? customerPhone,
}) async {
  try {
    await _client.from('appointments').insert({
      'user_id': currentUser!.id,
      'service_id': serviceId,
      'date': date,
      'time': time,
      'status': 'pending',
      'notes': notes ?? '',
      'customer_name': customerName ?? '',
      'customer_phone': customerPhone ?? '',
    });
  } catch (e) {
    print('INSERT HATA: $e');
    rethrow;
  }
}
// Kullanıcının sadakat puanını getir
static Future<int> getLoyaltyPoints() async {
  try {
    final response = await _client
        .from('loyalty_points')
        .select('points')
        .eq('user_id', currentUser!.id)
        .maybeSingle();
    return response?['points'] ?? 0;
  } catch (e) {
    return 0;
  }
}

// Sadakat geçmişini getir
static Future<List<Map<String, dynamic>>> getLoyaltyHistory() async {
  try {
    final response = await _client
        .from('loyalty_history')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
}

// Tüm müşterilerin puanlarını getir (admin için)
static Future<List<Map<String, dynamic>>> getAllLoyaltyPoints() async {
  try {
    final response = await _client
        .from('loyalty_points')
        .select('*, users(full_name, email, phone)')
        .order('points', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
}
}