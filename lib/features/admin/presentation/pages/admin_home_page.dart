import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services_management_page.dart';
import 'admin_appointments_tab.dart';
import 'admin_customers_tab.dart';
import 'admin_loyalty_tab.dart';
import 'admin_stats_tab.dart';
import 'admin_rewards_page.dart';
import 'admin_debt_page.dart';
import '../../../appointments/presentation/pages/new_appointment_sheet.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  final _mobileScaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Panel'),
    _NavItem(icon: Icons.calendar_month_outlined, label: 'Randevular'),
    _NavItem(icon: Icons.people_outline, label: 'Müşteriler'),
    _NavItem(icon: Icons.spa_outlined, label: 'Hizmetler'),
    _NavItem(icon: Icons.star_outline, label: 'Sadakat'),
    _NavItem(icon: Icons.card_giftcard_outlined, label: 'Ödüller'),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'İstatistikler'),
    _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Borç Takibi'),
  ];

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 1: return const AdminAppointmentsTab();
      case 2: return const AdminCustomersTab();
      case 4: return const AdminLoyaltyTab();
      case 6: return const AdminStatsTab();
      default: return _DashboardContent();
    }
  }

  void _handleNavItem(int index) {
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesManagementPage()));
    } else if (index == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRewardsPage()));
    } else if (index == 7) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDebtPage()));
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _handleLogout() async {
    await SupabaseService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return _buildTabletLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Row(
        children: [
          _Sidebar(
            width: 220,
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _handleNavItem,
            onLogout: _handleLogout,
          ),
          Expanded(
            child: _bodyForIndex(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _mobileScaffoldKey,
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFC9A84C)),
          onPressed: () => _mobileScaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _navItems[_selectedIndex].label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC9A84C),
            letterSpacing: 2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF5A4A2A), size: 20),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1208),
        width: 260,
        child: _Sidebar(
          width: null,
          navItems: _navItems,
          selectedIndex: _selectedIndex,
          onItemSelected: (i) {
            _mobileScaffoldKey.currentState?.closeDrawer();
            _handleNavItem(i);
          },
          onLogout: () {
            _mobileScaffoldKey.currentState?.closeDrawer();
            _handleLogout();
          },
        ),
      ),
      body: _bodyForIndex(_selectedIndex),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final double? width;
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const _Sidebar({
    this.width,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: const Color(0xFF1A1208),
      child: Column(
        children: [
          // Logo alanı
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 6),
                    child: Text(
                      'GENEL',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF5A4A2A),
                        letterSpacing: 2,
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
                    child: Text(
                      'İŞLETME',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF5A4A2A),
                        letterSpacing: 2,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC9A84C).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFC9A84C) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFFC9A84C)
                  : const Color(0xFF9A8A6A),
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
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

class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _services = [];
  String _adminName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = SupabaseService.currentUser;
      final appointments = await SupabaseService.getTodayAppointments();
      final services = await SupabaseService.getServices();

      String name = '';
      if (user != null) {
        final userData = await Supabase.instance.client
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = userData?['full_name'] ?? user.email ?? '';
      }

      setState(() {
        _appointments = appointments;
        _services = services.take(4).toList();
        _adminName = name.split(' ').first;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await SupabaseService.updateAppointmentStatus(id, status);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _adminName.isEmpty ? 'Hoş geldin ✦' : 'Hoş geldin, $_adminName ✦',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1208),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bugünün özetine göz atın',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A8A6A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const NewAppointmentSheet(),
                  );
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  foregroundColor: const Color(0xFF1A1208),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          const SizedBox(height: 20),

          // İstatistik kartları — 2×2 grid on mobile
          _buildStatCards(),
          const SizedBox(height: 20),

          // Randevu listesi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
            ),
            padding: const EdgeInsets.all(16),
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
                    GestureDetector(
                      onTap: _loadData,
                      child: const Icon(
                        Icons.refresh,
                        color: Color(0xFFC9A84C),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Color(0xFFC9A84C)),
                  )
                else if (_appointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Bugün randevu yok',
                      style: TextStyle(color: Color(0xFF9A8A6A)),
                    ),
                  )
                else
                  ..._appointments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final a = entry.value;
                    final name = (a['customer_name'] != null &&
                            a['customer_name'].toString().isNotEmpty)
                        ? a['customer_name']
                        : a['users']?['full_name'] ?? 'Misafir';
                    final initials =
                        name.split(' ').map((w) => w[0]).take(2).join();
                    final service = a['services']?['name'] ?? '';
                    final duration = a['services']?['duration_minutes'] ?? 0;
                    final time = a['time'].toString().substring(0, 5);
                    final status = a['status'];

                    return _AppointmentRow(
                      time: time,
                      initials: initials,
                      name: name,
                      service: '$service · $duration dk',
                      status: status == 'confirmed'
                          ? 'Onaylı'
                          : status == 'cancelled'
                              ? 'İptal'
                              : 'Bekliyor',
                      statusColor: status == 'confirmed'
                          ? const Color(0xFF2A6A2A)
                          : status == 'cancelled'
                              ? const Color(0xFF8A2A2A)
                              : const Color(0xFF8A5A10),
                      statusBg: status == 'confirmed'
                          ? const Color(0xFFEDF7EE)
                          : status == 'cancelled'
                              ? const Color(0xFFFDECEA)
                              : const Color(0xFFFDF4E3),
                      isLast: i == _appointments.length - 1,
                      onConfirm: status == 'pending'
                          ? () => _updateStatus(a['id'], 'confirmed')
                          : null,
                      onCancel: status == 'pending'
                          ? () => _updateStatus(a['id'], 'cancelled')
                          : null,
                    );
                  }),
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
          if (_services.isNotEmpty) _buildServiceCards(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = [
      _StatData('Bugün Randevu', '${_appointments.length}', 'Toplam randevu', null),
      _StatData(
        'Onaylı',
        '${_appointments.where((a) => a['status'] == 'confirmed').length}',
        'Onaylanmış',
        null,
      ),
      _StatData(
        'Bekleyen',
        '${_appointments.where((a) => a['status'] == 'pending').length}',
        'Onay bekliyor',
        const Color(0xFFC9A84C),
      ),
      _StatData(
        'İptal',
        '${_appointments.where((a) => a['status'] == 'cancelled').length}',
        'İptal edilmiş',
        const Color(0xFFA04030),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 500) {
          // 4 kart yan yana (tablet veya büyük ekran)
          return Row(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _StatCard(data: stats[i])),
              ],
            ],
          );
        }
        // 2×2 grid (telefon)
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(data: stats[0])),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(data: stats[1])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(data: stats[2])),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(data: stats[3])),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 500 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _services.map((s) {
            return SizedBox(
              width: itemWidth,
              child: _ServiceCard(
                name: s['name'] ?? '',
                price: '₺${s['price']}',
                duration: '${s['duration_minutes']} dk',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String delta;
  final Color? valueColor;
  const _StatData(this.label, this.value, this.delta, this.valueColor);
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9A8A6A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: data.valueColor ?? const Color(0xFF1A1208),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.delta,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A6A2A),
            ),
          ),
        ],
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
    final isPending = status == 'Bekliyor';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0EBE0), width: 0.5),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
                ),
              ),
              Container(
                width: 30,
                height: 30,
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
              const SizedBox(width: 10),
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
              if (!isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          // Bekliyor ise onayla/iptal butonlarını alt satıra al
          if (isPending)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 48),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7EE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '✓ Onayla',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A6A2A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '✕ İptal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A2A2A),
                        ),
                      ),
                    ),
                  ),
                ],
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

  const _ServiceCard({
    required this.name,
    required this.price,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFFC9A84C),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A)),
          ),
        ],
      ),
    );
  }
}
