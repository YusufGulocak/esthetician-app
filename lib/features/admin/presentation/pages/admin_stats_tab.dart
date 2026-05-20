import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';

class AdminStatsTab extends StatefulWidget {
  const AdminStatsTab({super.key});

  @override
  State<AdminStatsTab> createState() => _AdminStatsTabState();
}

class _AdminStatsTabState extends State<AdminStatsTab> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final stats = await SupabaseService.getMonthlyStats();
    final services = await SupabaseService.getServices();
    setState(() {
      _stats = stats;
      _services = services;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İstatistikler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
                  ),
                  Text(
                    '${months[now.month]} ${now.year}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, color: Color(0xFFC9A84C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          else ...[
            // Stat kartları
            Row(
              children: [
                _StatCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'Bu Ay Randevu',
                  value: '${_stats!['total']}',
                  color: const Color(0xFF5A8A6A),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Tamamlanan',
                  value: '${_stats!['confirmed']}',
                  color: const Color(0xFF2A6A2A),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  icon: Icons.payments_outlined,
                  label: 'Tahmini Gelir',
                  value: '₺${(_stats!['revenue'] as double).toStringAsFixed(0)}',
                  color: const Color(0xFFC9A84C),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.people_outline,
                  label: 'Toplam Müşteri',
                  value: '${_stats!['customerCount']}',
                  color: const Color(0xFF5A6A8A),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Onay oranı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Randevu Dağılımı',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
                  ),
                  const SizedBox(height: 16),
                  _DistributionRow(
                    label: 'Onaylı',
                    count: _stats!['confirmed'] as int,
                    total: _stats!['total'] as int,
                    color: const Color(0xFF2A6A2A),
                    bg: const Color(0xFFEDF7EE),
                  ),
                  const SizedBox(height: 10),
                  _DistributionRow(
                    label: 'Bekliyor',
                    count: _stats!['pending'] as int,
                    total: _stats!['total'] as int,
                    color: const Color(0xFF8A5A10),
                    bg: const Color(0xFFFDF4E3),
                  ),
                  const SizedBox(height: 10),
                  _DistributionRow(
                    label: 'İptal',
                    count: _stats!['cancelled'] as int,
                    total: _stats!['total'] as int,
                    color: const Color(0xFF8A2A2A),
                    bg: const Color(0xFFFDECEA),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Aktif hizmetler listesi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktif Hizmetler (${_services.length})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
                  ),
                  const SizedBox(height: 12),
                  ..._services.asMap().entries.map((e) {
                    final s = e.value;
                    final isLast = e.key == _services.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(bottom: BorderSide(color: Color(0xFFF0EBE0), width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name'] ?? '',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
                                ),
                                Text(
                                  '${s['duration_minutes']} dk · ${s['category'] ?? ''}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₺${s['price']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFC9A84C),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final Color bg;

  const _DistributionRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFF0EBE0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}
