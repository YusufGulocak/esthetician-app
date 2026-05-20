import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';

const _gold = Color(0xFFC9A84C);
const _dark = Color(0xFF1C1A16);
const _muted = Color(0xFF9A8A6A);
const _border = Color(0xFFE8DFC8);
const _red = Color(0xFF8A2A2A);
const _redBg = Color(0xFFFDECEA);
const _green = Color(0xFF2A6A2A);
const _greenBg = Color(0xFFEDF7EE);

class AdminDebtPage extends StatefulWidget {
  const AdminDebtPage({super.key});

  @override
  State<AdminDebtPage> createState() => _AdminDebtPageState();
}

class _AdminDebtPageState extends State<AdminDebtPage> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService.getDebtSummary();
    setState(() {
      _customers = data;
      _isLoading = false;
    });
  }

  double get _totalOutstanding => _customers.fold(0.0, (sum, c) {
        final b = (c['balance'] as num).toDouble();
        return sum + (b > 0 ? b : 0);
      });

  void _showDetail(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerDebtSheet(
        customer: customer,
        onChanged: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text(
          'Borç Takibi',
          style: TextStyle(color: _gold, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _gold, size: 20),
            onPressed: _load,
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : Column(
              children: [
                // ── Özet kart ──
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _gold.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF4E3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFF8A5A10), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Toplam Tahsil Edilecek',
                              style: TextStyle(fontSize: 12, color: _muted)),
                          Text(
                            '₺${_totalOutstanding.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700, color: _dark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Müşteri listesi ──
                Expanded(
                  child: _customers.isEmpty
                      ? const Center(
                          child: Text('Müşteri bulunamadı',
                              style: TextStyle(color: _muted, fontSize: 14)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _customers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final c = _customers[i];
                            final balance = (c['balance'] as num).toDouble();
                            final initials =
                                (c['full_name'] as String? ?? '?')[0].toUpperCase();
                            return GestureDetector(
                              onTap: () => _showDetail(c),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _gold.withValues(alpha: 0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(initials,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: _gold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c['full_name'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _dark)),
                                          if ((c['phone'] as String?)?.isNotEmpty == true)
                                            Text(c['phone'],
                                                style: const TextStyle(
                                                    fontSize: 12, color: _muted)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: balance > 0 ? _redBg : _greenBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        balance > 0
                                            ? '₺${balance.toStringAsFixed(2)}'
                                            : 'Temiz',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: balance > 0 ? _red : _green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right,
                                        color: _muted, size: 18),
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

// ─── Müşteri Detay Sheet ──────────────────────────────────────────────────────
class _CustomerDebtSheet extends StatefulWidget {
  final Map<String, dynamic> customer;
  final VoidCallback onChanged;

  const _CustomerDebtSheet({required this.customer, required this.onChanged});

  @override
  State<_CustomerDebtSheet> createState() => _CustomerDebtSheetState();
}

class _CustomerDebtSheetState extends State<_CustomerDebtSheet> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final h = await SupabaseService.getDebtHistory(widget.customer['id'] as String);
    setState(() {
      _history = h;
      _isLoading = false;
    });
  }

  double get _balance =>
      _history.fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

  void _showEntrySheet({required bool isDebt}) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Container(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: _border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                isDebt ? 'Borç Ekle' : 'Tahsilat Kaydet',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _dark),
              ),
              const SizedBox(height: 4),
              Text(widget.customer['full_name'] ?? '',
                  style: const TextStyle(fontSize: 13, color: _muted)),
              const SizedBox(height: 16),
              _inputField(amountCtrl, 'Tutar (₺)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 10),
              _inputField(descCtrl, 'Açıklama'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final amount = double.tryParse(
                              amountCtrl.text.replaceAll(',', '.'));
                          if (amount == null ||
                              amount <= 0 ||
                              descCtrl.text.trim().isEmpty) {
                            return;
                          }
                          set(() => saving = true);
                          try {
                            await SupabaseService.addDebtTransaction(
                              userId: widget.customer['id'] as String,
                              amount: isDebt ? amount : -amount,
                              description: descCtrl.text.trim(),
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            _loadHistory();
                            widget.onChanged();
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content: Text('Hata: $e'),
                                  backgroundColor: _red),
                            );
                          } finally {
                            if (ctx.mounted) set(() => saving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDebt ? _red : _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          isDebt ? 'Borç Ekle' : 'Tahsilatı Kaydet',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _balance;
    final name = widget.customer['full_name'] as String? ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Başlık ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: _border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _dark)),
                            if ((widget.customer['phone'] as String?)?.isNotEmpty == true)
                              Text(widget.customer['phone'] as String,
                                  style: const TextStyle(fontSize: 12, color: _muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: balance > 0 ? _redBg : _greenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          balance > 0
                              ? '₺${balance.toStringAsFixed(2)} Borçlu'
                              : 'Hesap Temiz',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: balance > 0 ? _red : _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEntrySheet(isDebt: true),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Borç Ekle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _red,
                            side: const BorderSide(color: _red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEntrySheet(isDebt: false),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Tahsilat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: _border),
                ],
              ),
            ),

            // ── Geçmiş ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _gold))
                  : _history.isEmpty
                      ? const Center(
                          child: Text('Henüz kayıt yok',
                              style: TextStyle(color: _muted, fontSize: 14)))
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          itemCount: _history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final t = _history[i];
                            final amt = (t['amount'] as num).toDouble();
                            final isDebt = amt > 0;
                            final dateStr =
                                (t['created_at'] as String).split('T')[0];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F6F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDebt ? _redBg : _greenBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDebt
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 16,
                                      color: isDebt ? _red : _green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(t['description'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: _dark)),
                                        Text(dateStr,
                                            style: const TextStyle(
                                                fontSize: 11, color: _muted)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isDebt ? '+' : '-'}₺${amt.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDebt ? _red : _green,
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
      ),
    );
  }
}

Widget _inputField(TextEditingController ctrl, String label,
    {TextInputType? keyboardType}) {
  return TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 13, color: _dark),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: _muted),
      filled: true,
      fillColor: const Color(0xFFFAFAF8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _gold, width: 1.5)),
    ),
  );
}
