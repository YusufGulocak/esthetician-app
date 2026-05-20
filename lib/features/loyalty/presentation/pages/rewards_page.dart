import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> _rewards = [];
  int _loyaltyPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final rewards = await SupabaseService.getRewards();
    final points = await SupabaseService.getLoyaltyPoints();
    setState(() {
      _rewards = rewards;
      _loyaltyPoints = points;
      _isLoading = false;
    });
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    final pointsRequired = reward['points_required'] as int;

    if (_loyaltyPoints < pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli puanınız yok'),
          backgroundColor: Color(0xFF8A2A2A),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ödülü Kullan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text('${reward['name']} ödülünü $pointsRequired puan karşılığında kullanmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Color(0xFF9A8A6A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A84C),
              foregroundColor: const Color(0xFF1A1208),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Kullan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await SupabaseService.redeemReward(
      rewardId: reward['id'],
      pointsRequired: pointsRequired,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reward['name']} ödülünüz kullanıldı!'),
        backgroundColor: const Color(0xFF2A6A2A),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text(
          'Ödüllerim',
          style: TextStyle(color: Color(0xFFC9A84C), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC9A84C)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: const Color(0xFF1A1208),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mevcut Puanınız',
                            style: TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
                          ),
                          Text(
                            '$_loyaltyPoints Puan',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFC9A84C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kullanılabilir Ödüller',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1208),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _rewards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = _rewards[i];
                      final pointsRequired = r['points_required'] as int;
                      final canRedeem = _loyaltyPoints >= pointsRequired;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: canRedeem
                                ? const Color(0xFFC9A84C).withValues(alpha: 0.3)
                                : const Color(0xFFE8E0D0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: canRedeem
                                    ? const Color(0xFFC9A84C).withValues(alpha: 0.1)
                                    : const Color(0xFFF0EBE0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.card_giftcard,
                                color: canRedeem
                                    ? const Color(0xFFC9A84C)
                                    : const Color(0xFFB0A080),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['name'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: canRedeem
                                          ? const Color(0xFF1A1208)
                                          : const Color(0xFF9A8A6A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r['description'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$pointsRequired puan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFC9A84C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            canRedeem
                                ? ElevatedButton(
                                    onPressed: () => _redeemReward(r),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1208),
                                      foregroundColor: const Color(0xFFC9A84C),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    child: const Text('Kullan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EBE0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${pointsRequired - _loyaltyPoints} puan eksik',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF9A8A6A)),
                                    ),
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
