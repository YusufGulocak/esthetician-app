import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';

class AdminRewardsPage extends StatefulWidget {
  const AdminRewardsPage({super.key});

  @override
  State<AdminRewardsPage> createState() => _AdminRewardsPageState();
}

class _AdminRewardsPageState extends State<AdminRewardsPage> {
  List<Map<String, dynamic>> _rewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    final rewards = await SupabaseService.getAllRewards();
    setState(() {
      _rewards = rewards;
      _isLoading = false;
    });
  }

  void _showRewardDialog({Map<String, dynamic>? reward}) {
    final nameController = TextEditingController(text: reward?['name'] ?? '');
    final descController = TextEditingController(text: reward?['description'] ?? '');
    final pointsController = TextEditingController(
      text: reward != null ? '${reward['points_required']}' : '',
    );
    bool isActive = reward?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            reward == null ? 'Yeni Ödül' : 'Ödülü Düzenle',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogLabel('Ödül Adı *'),
                const SizedBox(height: 6),
                _dialogField(nameController, 'Örn: %10 İndirim'),
                const SizedBox(height: 14),
                _dialogLabel('Açıklama'),
                const SizedBox(height: 6),
                _dialogField(descController, 'Kısa açıklama...', maxLines: 2),
                const SizedBox(height: 14),
                _dialogLabel('Gerekli Puan *'),
                const SizedBox(height: 6),
                _dialogField(pointsController, '500', keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Aktif', style: TextStyle(fontSize: 13, color: Color(0xFF1A1208))),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      activeThumbColor: const Color(0xFFC9A84C),
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Color(0xFF9A8A6A))),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final points = int.tryParse(pointsController.text.trim());
                if (name.isEmpty || points == null || points <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ödül adı ve geçerli puan değeri girin'),
                      backgroundColor: Color(0xFF8A2A2A),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                if (reward == null) {
                  await SupabaseService.addReward(
                    name: name,
                    description: descController.text.trim(),
                    pointsRequired: points,
                    isActive: isActive,
                  );
                } else {
                  await SupabaseService.updateReward(
                    id: reward['id'],
                    name: name,
                    description: descController.text.trim(),
                    pointsRequired: points,
                    isActive: isActive,
                  );
                }
                _loadRewards();
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

  Future<void> _deleteReward(Map<String, dynamic> reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ödülü Sil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text('${reward['name']} ödülünü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Color(0xFF9A8A6A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2A2A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await SupabaseService.deleteReward(reward['id']);
    _loadRewards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text(
          'Ödül Yönetimi',
          style: TextStyle(color: Color(0xFFC9A84C), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC9A84C)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFC9A84C)),
            onPressed: () => _showRewardDialog(),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : _rewards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.card_giftcard_outlined, color: Color(0xFFE8E0D0), size: 60),
                      const SizedBox(height: 16),
                      const Text('Henüz ödül eklenmemiş', style: TextStyle(color: Color(0xFF9A8A6A), fontSize: 14)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showRewardDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ödül Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A84C),
                          foregroundColor: const Color(0xFF1A1208),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _rewards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = _rewards[i];
                    final isActive = r['is_active'] as bool? ?? true;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E0D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFC9A84C).withValues(alpha: 0.1)
                                  : const Color(0xFFF0EBE0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: isActive ? const Color(0xFFC9A84C) : const Color(0xFFB0A080),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      r['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isActive ? const Color(0xFF1A1208) : const Color(0xFF9A8A6A),
                                      ),
                                    ),
                                    if (!isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0EBE0),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Pasif', style: TextStyle(fontSize: 10, color: Color(0xFF9A8A6A))),
                                      ),
                                    ],
                                  ],
                                ),
                                if ((r['description'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(r['description'], style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 13),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${r['points_required']} puan',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF9A8A6A), size: 20),
                            onPressed: () => _showRewardDialog(reward: r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFF8A2A2A), size: 20),
                            onPressed: () => _deleteReward(r),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _dialogLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
      );

  Widget _dialogField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1208)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9A8A6A), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFFAF7F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
}
