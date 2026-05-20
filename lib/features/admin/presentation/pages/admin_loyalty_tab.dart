import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';

class AdminLoyaltyTab extends StatefulWidget {
  const AdminLoyaltyTab({super.key});

  @override
  State<AdminLoyaltyTab> createState() => _AdminLoyaltyTabState();
}

class _AdminLoyaltyTabState extends State<AdminLoyaltyTab> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService.getAllLoyaltyPoints();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  void _showAdjustDialog(Map<String, dynamic> entry) {
    final user = entry['users'];
    final userId = entry['user_id'] as String;
    final currentPoints = entry['points'] as int;
    final pointsCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    bool isAdd = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Puan Düzenle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                user?['full_name'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A), fontWeight: FontWeight.w400),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mevcut puan: $currentPoints',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9A8A6A)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => isAdd = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isAdd ? const Color(0xFFC9A84C) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E0D0)),
                        ),
                        child: Text(
                          '+ Ekle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isAdd ? const Color(0xFF1A1208) : const Color(0xFF9A8A6A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => isAdd = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isAdd ? const Color(0xFFFDECEA) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E0D0)),
                        ),
                        child: Text(
                          '− Çıkar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: !isAdd ? const Color(0xFF8A2A2A) : const Color(0xFF9A8A6A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Puan miktarı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Color(0xFF9A8A6A))),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(pointsCtrl.text.trim()) ?? 0;
                if (amount <= 0) return;
                final delta = isAdd ? amount : -amount;
                final reason = reasonCtrl.text.trim().isNotEmpty
                    ? reasonCtrl.text.trim()
                    : (isAdd ? 'Admin tarafından eklendi' : 'Admin tarafından çıkarıldı');
                Navigator.pop(ctx);
                await SupabaseService.adjustLoyaltyPoints(
                  userId: userId,
                  pointsDelta: delta,
                  reason: reason,
                );
                _load();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A84C),
                foregroundColor: const Color(0xFF1A1208),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
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
                'Sadakat Puanları',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
              ),
              const Spacer(),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh, color: Color(0xFFC9A84C), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Müşterilerin puanlarını görüntüleyin ve düzenleyin',
            style: TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C))))
          else if (_data.isEmpty)
            const Expanded(
              child: Center(child: Text('Veri bulunamadı', style: TextStyle(color: Color(0xFF9A8A6A)))),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final entry = _data[i];
                  final user = entry['users'];
                  final name = user?['full_name'] ?? 'İsimsiz';
                  final points = entry['points'] as int;
                  final initials = name
                      .toString()
                      .split(' ')
                      .map((w) => w.isNotEmpty ? w[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase();

                  return Container(
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDE8DF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A6040),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1208),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?['email'] ?? '',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
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
                                  Text(
                                    '$points',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFC9A84C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showAdjustDialog(entry),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1208),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Düzenle',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C)),
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
}
