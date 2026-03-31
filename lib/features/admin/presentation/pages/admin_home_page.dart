import 'package:flutter/material.dart';
import 'package:dilan_beauty_app/features/appointments/presentation/pages/new_appointment_sheet.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Panel'),
    _NavItem(icon: Icons.calendar_month_outlined, label: 'Randevular'),
    _NavItem(icon: Icons.people_outline, label: 'Müşteriler'),
    _NavItem(icon: Icons.spa_outlined, label: 'Hizmetler'),
    _NavItem(icon: Icons.star_outline, label: 'Sadakat'),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'İstatistikler'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Row(
        children: [
          // Sidebar
          _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
            onLogout: () async {
              await SupabaseService.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          // Ana içerik
          Expanded(
            child: _DashboardContent(),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1A1208),
      child: Column(
        children: [
          // Logo alanı
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF3A2E1A)),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DILAN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC9A84C),
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  'BEAUTY LOUNGE',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF5A4A2A),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GENEL',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF5A4A2A),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  ...navItems.sublist(0, 3).asMap().entries.map(
                        (e) => _NavTile(
                          item: e.value,
                          isSelected: selectedIndex == e.key,
                          onTap: () => onItemSelected(e.key),
                        ),
                      ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'İŞLETME',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF5A4A2A),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  ...navItems.sublist(3).asMap().entries.map(
                        (e) => _NavTile(
                          item: e.value,
                          isSelected: selectedIndex == e.key + 3,
                          onTap: () => onItemSelected(e.key + 3),
                        ),
                      ),
                ],
              ),
            ),
          ),
          // Alt kullanıcı alanı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF3A2E1A)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC9A84C),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A1208),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dilan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC9A84C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF5A4A2A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF5A4A2A),
                    size: 16,
                  ),
                  onPressed: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC9A84C).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isSelected
                  ? const Color(0xFFC9A84C)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFFC9A84C)
                  : const Color(0xFF9A8A6A),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? const Color(0xFFC9A84C)
                    : const Color(0xFF9A8A6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst bar
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş geldin, Dilan ✦',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1208),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bugünün özetine göz atın',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A8A6A),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NewAppointmentSheet(),
  );
},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  foregroundColor: const Color(0xFF1A1208),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Yeni Randevu',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // İstatistik kartları
          Row(
            children: [
              _StatCard(
                label: 'Bugün Randevu',
                value: '8',
                delta: '↑ 2 dünden fazla',
                positive: true,
              ),
              const SizedBox(width: 14),
              _StatCard(
                label: 'Günlük Gelir',
                value: '₺3.240',
                delta: '↑ %12 bu hafta',
                positive: true,
              ),
              const SizedBox(width: 14),
              _StatCard(
                label: 'Aktif Müşteri',
                value: '142',
                delta: '↑ 7 bu ay',
                positive: true,
              ),
              const SizedBox(width: 14),
              _StatCard(
                label: 'Bekleyen Onay',
                value: '3',
                delta: 'Onay bekliyor',
                positive: false,
                valueColor: const Color(0xFFC9A84C),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Randevu listesi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Bugünün Randevuları',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1208),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Tümünü gör →',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC9A84C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _AppointmentRow(
  time: '12:00',
  initials: 'SÖ',
  name: 'Selin Öztürk',
  service: 'Makyaj · 90 dk',
  status: 'Bekliyor',
  statusColor: const Color(0xFF8A5A10),
  statusBg: const Color(0xFFFDF4E3),
  onConfirm: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu onaylandı'),
        backgroundColor: Color(0xFF2A6A2A),
      ),
    );
  },
  onCancel: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu iptal edildi'),
        backgroundColor: Color(0xFF8A2A2A),
      ),
    );
  },
),
_AppointmentRow(
  time: '14:00',
  initials: 'NB',
  name: 'Naz Bayrak',
  service: 'Saç Bakımı · 45 dk',
  status: 'Bekliyor',
  statusColor: const Color(0xFF8A5A10),
  statusBg: const Color(0xFFFDF4E3),
  onConfirm: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu onaylandı'),
        backgroundColor: Color(0xFF2A6A2A),
      ),
    );
  },
  onCancel: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu iptal edildi'),
        backgroundColor: Color(0xFF8A2A2A),
      ),
    );
  },
),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hizmetler
          const Text(
            'Popüler Hizmetler',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1208),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ServiceCard(name: 'Cilt Bakımı', price: '₺450', duration: '60 dk', count: '28 bu ay'),
              const SizedBox(width: 12),
              _ServiceCard(name: 'Kaş Tasarımı', price: '₺180', duration: '30 dk', count: '41 bu ay'),
              const SizedBox(width: 12),
              _ServiceCard(name: 'Kalıcı Makyaj', price: '₺1.200', duration: '120 dk', count: '12 bu ay'),
              const SizedBox(width: 12),
              _ServiceCard(name: 'Epilasyon', price: '₺280', duration: '45 dk', count: '35 bu ay'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final bool positive;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9A8A6A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF1A1208),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              delta,
              style: TextStyle(
                fontSize: 11,
                color: positive
                    ? const Color(0xFF8A6A2A)
                    : const Color(0xFF8A5A10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final String time;
  final String initials;
  final String name;
  final String service;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final bool isLast;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _AppointmentRow({
    required this.time,
    required this.initials,
    required this.name,
    required this.service,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    this.isLast = false,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0EBE0), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9A8A6A),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8DF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A6040),
                ),
              ),
            ),
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
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1208),
                  ),
                ),
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9A8A6A),
                  ),
                ),
              ],
            ),
          ),
          // Bekliyor ise onay/iptal butonları göster
          if (status == 'Bekliyor') ...[
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✓ Onayla',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2A6A2A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✕ İptal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A2A2A),
                  ),
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final String count;

  const _ServiceCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
        ),
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
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC9A84C),
              ),
            ),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9A8A6A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '↑ $count',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7A8A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}