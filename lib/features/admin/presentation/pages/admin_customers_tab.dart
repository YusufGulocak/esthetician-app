import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_service.dart';

class AdminCustomersTab extends StatefulWidget {
  const AdminCustomersTab({super.key});

  @override
  State<AdminCustomersTab> createState() => _AdminCustomersTabState();
}

class _AdminCustomersTabState extends State<AdminCustomersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService.getAllUsers();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users.where((u) {
      final name = (u['full_name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final phone = (u['phone'] ?? '').toString();
      return name.contains(q) || email.contains(q) || phone.contains(q);
    }).toList();
  }

  void _showCustomerDetail(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerDetailSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Müşteriler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
              ),
              const Spacer(),
              Text(
                '${_users.length} müşteri',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, color: Color(0xFFC9A84C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'İsim, e-posta veya telefon ara...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9A8A6A)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9A8A6A), size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8E0D0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8E0D0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC9A84C))),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C))))
          else if (_filtered.isEmpty)
            const Expanded(
              child: Center(child: Text('Müşteri bulunamadı', style: TextStyle(color: Color(0xFF9A8A6A)))),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final u = _filtered[i];
                  final name = u['full_name'] ?? 'İsimsiz';
                  final email = u['email'] ?? '';
                  final phone = u['phone'] ?? '';
                  final pointsData = u['loyalty_points'];
                  final points = pointsData is List && pointsData.isNotEmpty
                      ? pointsData[0]['points'] ?? 0
                      : (pointsData is Map ? pointsData['points'] ?? 0 : 0);
                  final initials = name.toString().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

                  return GestureDetector(
                    onTap: () => _showCustomerDetail(u),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(color: Color(0xFFEDE8DF), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF7A6040)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                                const SizedBox(height: 2),
                                Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
                                if (phone.toString().isNotEmpty)
                                  Text(phone, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A84C).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 13),
                                const SizedBox(width: 4),
                                Text('$points', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Color(0xFF9A8A6A), size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomerDetailSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  const _CustomerDetailSheet({required this.user});

  @override
  State<_CustomerDetailSheet> createState() => _CustomerDetailSheetState();
}

class _CustomerDetailSheetState extends State<_CustomerDetailSheet> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, services(name, duration_minutes, price)')
          .eq('user_id', widget.user['id'])
          .order('date', ascending: false)
          .limit(20);
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['full_name'] ?? 'İsimsiz';
    final email = widget.user['email'] ?? '';
    final phone = widget.user['phone'] ?? '';
    final pointsData = widget.user['loyalty_points'];
    final points = pointsData is List && pointsData.isNotEmpty
        ? pointsData[0]['points'] ?? 0
        : (pointsData is Map ? pointsData['points'] ?? 0 : 0);
    final initials = name.toString().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE8E0D0), borderRadius: BorderRadius.circular(2)),
          ),
          // Müşteri başlık kartı
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1208),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(color: Color(0xFFC9A84C), shape: BoxShape.circle),
                  child: Center(
                    child: Text(initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1208))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFC9A84C))),
                      const SizedBox(height: 2),
                      if (email.isNotEmpty)
                        Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                      if (phone.toString().isNotEmpty)
                        Text(phone, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 20),
                    const SizedBox(height: 2),
                    Text('$points', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFC9A84C))),
                    const Text('puan', style: TextStyle(fontSize: 10, color: Color(0xFF9A8A6A))),
                  ],
                ),
              ],
            ),
          ),
          // Randevu geçmişi başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Randevu Geçmişi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                const Spacer(),
                Text('${_appointments.length} randevu', style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Randevular listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
                : _appointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_outlined, color: Color(0xFFE8E0D0), size: 48),
                            SizedBox(height: 12),
                            Text('Henüz randevu yok', style: TextStyle(color: Color(0xFF9A8A6A), fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final a = _appointments[i];
                          final service = a['services'];
                          final status = a['status'] as String? ?? 'pending';
                          final statusLabel = status == 'confirmed' ? 'Onaylı' : status == 'cancelled' ? 'İptal' : 'Bekliyor';
                          final statusColor = status == 'confirmed'
                              ? const Color(0xFF2A6A2A)
                              : status == 'cancelled'
                                  ? const Color(0xFF8A2A2A)
                                  : const Color(0xFF8A5A10);
                          final statusBg = status == 'confirmed'
                              ? const Color(0xFFEDF7EE)
                              : status == 'cancelled'
                                  ? const Color(0xFFFDECEA)
                                  : const Color(0xFFFDF4E3);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9A84C).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.spa_outlined, color: Color(0xFFC9A84C), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service?['name'] ?? '',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${a['date']} · ${(a['time'] as String).substring(0, 5)}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
                                      ),
                                      if (service?['price'] != null)
                                        Text(
                                          '₺${service!['price']} · ${service['duration_minutes']} dk',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
