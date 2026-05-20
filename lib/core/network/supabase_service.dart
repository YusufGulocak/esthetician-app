import 'dart:io';
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

// Şifre sıfırlama e-postası gönder
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

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
    rethrow;
  }
}
// Kullanıcının yaklaşan randevusunu getir
static Future<Map<String, dynamic>?> getNextAppointment() async {
  try {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('appointments')
        .select('*, services(name, duration_minutes, price)')
        .eq('user_id', currentUser!.id)
        .neq('status', 'cancelled')
        .gte('date', today)
        .order('date', ascending: true)
        .order('time', ascending: true)
        .limit(1)
        .maybeSingle();
    return response;
  } catch (e) {
    return null;
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
// Tüm randevuları getir (admin, opsiyonel durum filtresi)
static Future<List<Map<String, dynamic>>> getAllAppointments({String? statusFilter}) async {
  var query = _client
      .from('appointments')
      .select('*, services(name, duration_minutes, price), users(full_name, phone)');
  if (statusFilter != null) {
    query = query.eq('status', statusFilter);
  }
  final response = await query.order('date', ascending: false).order('time', ascending: true);
  return List<Map<String, dynamic>>.from(response);
}

// Tüm müşterileri loyalty puanlarıyla getir (admin)
static Future<List<Map<String, dynamic>>> getAllUsers() async {
  final response = await _client
      .from('users')
      .select('*, loyalty_points(points)')
      .eq('role', 'customer')
      .order('full_name');
  return List<Map<String, dynamic>>.from(response);
}

// Manuel puan ekle/çıkar (admin)
static Future<void> adjustLoyaltyPoints({
  required String userId,
  required int pointsDelta,
  required String reason,
}) async {
  final current = await _client
      .from('loyalty_points')
      .select('points')
      .eq('user_id', userId)
      .maybeSingle();
  final currentPoints = (current?['points'] ?? 0) as int;
  final newPoints = (currentPoints + pointsDelta).clamp(0, 999999);
  if (current == null) {
    await _client.from('loyalty_points').insert({'user_id': userId, 'points': newPoints});
  } else {
    await _client.from('loyalty_points').update({
      'points': newPoints,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }
  await _client.from('loyalty_history').insert({
    'user_id': userId,
    'points_change': pointsDelta,
    'reason': reason,
  });
}

// Aylık istatistikler (admin)
static Future<Map<String, dynamic>> getMonthlyStats() async {
  final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1)
      .toIso8601String()
      .split('T')[0];
  final appointments = await _client
      .from('appointments')
      .select('status, services(price)')
      .gte('date', startOfMonth);
  final list = List<Map<String, dynamic>>.from(appointments);
  final confirmed = list.where((a) => a['status'] == 'confirmed').toList();
  final revenue = confirmed.fold<double>(
    0,
    (sum, a) => sum + ((a['services']?['price'] ?? 0) as num).toDouble(),
  );
  final users = await _client.from('users').select('id').eq('role', 'customer');
  return {
    'total': list.length,
    'confirmed': confirmed.length,
    'cancelled': list.where((a) => a['status'] == 'cancelled').length,
    'pending': list.where((a) => a['status'] == 'pending').length,
    'revenue': revenue,
    'customerCount': (users as List).length,
  };
}

// Hizmet ekle — yeni satırın ID'sini döner
static Future<String> addService({
  required String name,
  required String description,
  required double price,
  required int durationMinutes,
  required String category,
}) async {
  final response = await _client.from('services').insert({
    'name': name,
    'description': description,
    'price': price,
    'duration_minutes': durationMinutes,
    'category': category,
    'is_active': true,
  }).select('id').single();
  return response['id'] as String;
}

// Hizmet fotoğrafı yükle (Storage: services bucket)
static Future<String> uploadServiceImage(File imageFile, String serviceId) async {
  final ext = imageFile.path.split('.').last.toLowerCase();
  final path = '$serviceId/cover.$ext';
  await _client.storage.from('services').upload(
    path,
    imageFile,
    fileOptions: const FileOptions(upsert: true),
  );
  final url = _client.storage.from('services').getPublicUrl(path);
  return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
}

// Hizmet fotoğraf URL'ini güncelle
static Future<void> updateServiceImage(String serviceId, String imageUrl) async {
  await _client.from('services').update({'image_url': imageUrl}).eq('id', serviceId);
}

// Hizmet güncelle
static Future<void> updateService({
  required String id,
  required String name,
  required String description,
  required double price,
  required int durationMinutes,
  required String category,
}) async {
  await _client.from('services').update({
    'name': name,
    'description': description,
    'price': price,
    'duration_minutes': durationMinutes,
    'category': category,
  }).eq('id', id);
}
// Aktif ödülleri getir (müşteri tarafı)
static Future<List<Map<String, dynamic>>> getRewards() async {
  try {
    final response = await _client
        .from('rewards')
        .select()
        .eq('is_active', true)
        .order('points_required');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
}

// Tüm ödülleri getir (admin tarafı)
static Future<List<Map<String, dynamic>>> getAllRewards() async {
  try {
    final response = await _client
        .from('rewards')
        .select()
        .order('points_required');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
}

// Ödül ekle (admin)
static Future<void> addReward({
  required String name,
  required String description,
  required int pointsRequired,
  required bool isActive,
}) async {
  await _client.from('rewards').insert({
    'name': name,
    'description': description,
    'points_required': pointsRequired,
    'is_active': isActive,
  });
}

// Ödül güncelle (admin)
static Future<void> updateReward({
  required String id,
  required String name,
  required String description,
  required int pointsRequired,
  required bool isActive,
}) async {
  await _client.from('rewards').update({
    'name': name,
    'description': description,
    'points_required': pointsRequired,
    'is_active': isActive,
  }).eq('id', id);
}

// Ödül sil (admin)
static Future<void> deleteReward(String id) async {
  await _client.from('rewards').delete().eq('id', id);
}

// Profil güncelle
static Future<void> updateProfile({
  required String fullName,
  required String phone,
  String? avatarUrl,
}) async {
  final data = <String, dynamic>{
    'full_name': fullName,
    'phone': phone,
  };
  if (avatarUrl != null) data['avatar_url'] = avatarUrl;
  await _client.from('users').update(data).eq('id', currentUser!.id);
}

// Profil fotoğrafı yükle (Supabase Storage: avatars bucket)
static Future<String> uploadAvatar(File imageFile) async {
  final userId = currentUser!.id;
  final ext = imageFile.path.split('.').last.toLowerCase();
  final path = '$userId/avatar.$ext';

  await _client.storage.from('avatars').upload(
    path,
    imageFile,
    fileOptions: const FileOptions(upsert: true),
  );

  final url = _client.storage.from('avatars').getPublicUrl(path);
  // Cache-buster ekle — fotoğraf değişince eski URL'yi göstermesin
  return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
}

// Borç özeti: her müşteri için net bakiyeyi hesapla
static Future<List<Map<String, dynamic>>> getDebtSummary() async {
  final users = await _client
      .from('users')
      .select('id, full_name, phone')
      .eq('role', 'customer')
      .order('full_name');
  final txns = await _client
      .from('debt_transactions')
      .select('user_id, amount');
  final Map<String, double> balances = {};
  for (final t in List<Map<String, dynamic>>.from(txns)) {
    final uid = t['user_id'] as String;
    balances[uid] = (balances[uid] ?? 0) + (t['amount'] as num).toDouble();
  }
  return List<Map<String, dynamic>>.from(users).map((u) {
    return {...u, 'balance': balances[u['id'] as String] ?? 0.0};
  }).toList();
}

// Bir müşterinin borç/tahsilat geçmişi
static Future<List<Map<String, dynamic>>> getDebtHistory(String userId) async {
  final response = await _client
      .from('debt_transactions')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
}

// Borç veya tahsilat kaydı ekle (amount > 0 borç, < 0 tahsilat)
static Future<void> addDebtTransaction({
  required String userId,
  required double amount,
  required String description,
}) async {
  await _client.from('debt_transactions').insert({
    'user_id': userId,
    'amount': amount,
    'description': description,
  });
}

// Ödül kullan
static Future<void> redeemReward({
  required String rewardId,
  required int pointsRequired,
}) async {
  final userId = currentUser!.id;

  // Puanı düş
  await _client.from('loyalty_points').update({
    'points': await getLoyaltyPoints() - pointsRequired,
    'updated_at': DateTime.now().toIso8601String(),
  }).eq('user_id', userId);

  // Geçmişe ekle
  await _client.from('loyalty_history').insert({
    'user_id': userId,
    'points_change': -pointsRequired,
    'reason': 'Ödül kullanıldı: $rewardId',
  });
}
}