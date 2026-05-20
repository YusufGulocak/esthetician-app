import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/supabase_service.dart';

class AdminAppointmentsTab extends StatefulWidget {
  const AdminAppointmentsTab({super.key});

  @override
  State<AdminAppointmentsTab> createState() => _AdminAppointmentsTabState();
}

class _AdminAppointmentsTabState extends State<AdminAppointmentsTab> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tümü';

  static const _filters = ['Tümü', 'Bekliyor', 'Onaylı', 'İptal'];
  static const _statusMap = {
    'Bekliyor': 'pending',
    'Onaylı': 'confirmed',
    'İptal': 'cancelled',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final statusFilter = _statusMap[_selectedFilter];
    final data = await SupabaseService.getAllAppointments(statusFilter: statusFilter);
    setState(() {
      _appointments = data;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await SupabaseService.updateAppointmentStatus(id, status);
    _load();
  }

  Future<void> _sendWhatsApp({
    required String phone,
    required String name,
    required String serviceName,
    required String date,
    required String time,
  }) async {
    if (phone.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu müşterinin telefon numarası yok'),
          backgroundColor: Color(0xFF8A2A2A),
        ),
      );
      return;
    }

    // Numara normalizasyonu: 05xx → 905xx, +90 → 90
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    } else if (normalized.startsWith('0')) {
      normalized = '90${normalized.substring(1)}';
    } else if (normalized.startsWith('5')) {
      normalized = '90$normalized';
    }

    final message = Uri.encodeComponent(
      'Merhaba $name 👋\n\n'
      'Dilan Beauty Lounge randevunuz onaylandı ✅\n\n'
      '📅 Tarih: ${_formatDate(date)}\n'
      '⏰ Saat: $time\n'
      '💆 Hizmet: $serviceName\n\n'
      'Görüşmek üzere 🌟',
    );

    final url = Uri.parse('https://wa.me/$normalized?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp açılamadı'),
          backgroundColor: Color(0xFF8A2A2A),
        ),
      );
    }
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[m]} ${parts[0]}';
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
                'Randevular',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1208)),
              ),
              const Spacer(),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh,
                    color: Color(0xFFC9A84C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filtre chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = f);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A1208)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC9A84C)
                              : const Color(0xFFE8E0D0),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFC9A84C)
                              : const Color(0xFF9A8A6A),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFC9A84C))))
          else if (_appointments.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Randevu bulunamadı',
                    style: TextStyle(color: Color(0xFF9A8A6A))),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _appointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = _appointments[i];
                  final status = a['status'] as String;
                  final name =
                      (a['customer_name']?.toString().isNotEmpty == true)
                          ? a['customer_name'] as String
                          : a['users']?['full_name'] as String? ?? 'Misafir';
                  final serviceName =
                      a['services']?['name'] as String? ?? '';
                  final date = a['date'] as String? ?? '';
                  final time =
                      a['time'].toString().substring(0, 5);
                  final phone =
                      (a['customer_phone']?.toString().isNotEmpty == true)
                          ? a['customer_phone'] as String
                          : a['users']?['phone'] as String? ?? '';

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFE8E0D0), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Üst satır: avatar + bilgi ──
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A84C)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person_outline,
                                  color: Color(0xFFC9A84C), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1208)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$serviceName · $date $time',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9A8A6A)),
                                  ),
                                  if (phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9A8A6A)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF0EBE0)),
                        const SizedBox(height: 10),

                        // ── Alt satır: aksiyon butonları ──
                        Row(
                          children: [
                            if (status == 'pending') ...[
                              _actionChip(
                                label: '✓ Onayla',
                                bg: const Color(0xFFEDF7EE),
                                fg: const Color(0xFF2A6A2A),
                                onTap: () =>
                                    _updateStatus(a['id'] as String, 'confirmed'),
                              ),
                              const SizedBox(width: 6),
                              _actionChip(
                                label: '✕ İptal',
                                bg: const Color(0xFFFDECEA),
                                fg: const Color(0xFF8A2A2A),
                                onTap: () =>
                                    _updateStatus(a['id'] as String, 'cancelled'),
                              ),
                            ] else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == 'confirmed'
                                      ? const Color(0xFFEDF7EE)
                                      : const Color(0xFFFDECEA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status == 'confirmed' ? 'Onaylı' : 'İptal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: status == 'confirmed'
                                        ? const Color(0xFF2A6A2A)
                                        : const Color(0xFF8A2A2A),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            // WhatsApp butonu (iptal hariç)
                            if (status != 'cancelled')
                              GestureDetector(
                                onTap: () => _sendWhatsApp(
                                  phone: phone,
                                  name: name,
                                  serviceName: serviceName,
                                  date: date,
                                  time: time,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.chat_outlined,
                                          color: Color(0xFF25D366), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'WhatsApp',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A7A38),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: fg),
        ),
      ),
    );
  }
}
