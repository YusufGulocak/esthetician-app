import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../appointments/presentation/pages/book_appointment_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _AppointmentsTab(),
    const _ServicesTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8E0D0), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFC9A84C),
          unselectedItemColor: const Color(0xFF9A8A6A),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month_rounded), label: 'Randevular'),
            BottomNavigationBarItem(icon: Icon(Icons.spa_outlined), activeIcon: Icon(Icons.spa_rounded), label: 'Hizmetler'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _loyaltyPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final points = await SupabaseService.getLoyaltyPoints();
    setState(() => _loyaltyPoints = points);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              color: const Color(0xFF1A1208),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Merhaba 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C))),
                          SizedBox(height: 4),
                          Text('Bugün kendinize iyi bakın', style: TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: const Color(0xFFC9A84C), shape: BoxShape.circle),
                        child: const Center(child: Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1208)))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1E0E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFC9A84C), size: 28),
                        const SizedBox(width: 12),
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sadakat Puanınız', style: TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
                           Text(
  '$_loyaltyPoints Puan',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFFC9A84C),
  ),
),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFC9A84C), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Ödülleri Gör', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1208))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yaklaşan Randevunuz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E0D0))),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFC9A84C).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.spa_outlined, color: Color(0xFFC9A84C), size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cilt Bakımı', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                              SizedBox(height: 4),
                              Text('28 Mart 2026 · 14:00', style: TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEDF7EE), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Onaylı', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2A6A2A))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Popüler Hizmetler', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: const [
                      _ServiceCard(name: 'Cilt Bakımı', price: '₺450', duration: '60 dk', icon: Icons.face_retouching_natural),
                      _ServiceCard(name: 'Kaş Tasarımı', price: '₺180', duration: '30 dk', icon: Icons.auto_fix_high),
                      _ServiceCard(name: 'Kalıcı Makyaj', price: '₺1.200', duration: '120 dk', icon: Icons.brush_outlined),
                      _ServiceCard(name: 'Epilasyon', price: '₺280', duration: '45 dk', icon: Icons.spa_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
),
                      child: const Text('Randevu Al', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final IconData icon;

  const _ServiceCard({required this.name, required this.price, required this.duration, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E0D0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC9A84C), size: 22),
          const Spacer(),
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(price, style: const TextStyle(fontSize: 12, color: Color(0xFFC9A84C), fontWeight: FontWeight.w500)),
              const Text(' · ', style: TextStyle(color: Color(0xFF9A8A6A), fontSize: 12)),
              Text(duration, style: const TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, services(name, duration_minutes, price)')
          .eq('user_id', SupabaseService.currentUser!.id)
          .order('date', ascending: false);
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Randevularım',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1208),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _loadAppointments,
                  child: const Icon(Icons.refresh, color: Color(0xFFC9A84C), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
            else if (_appointments.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(Icons.calendar_month_outlined, color: Color(0xFFE8E0D0), size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz randevunuz yok',
                      style: TextStyle(color: Color(0xFF9A8A6A), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Randevu Al →',
                        style: TextStyle(color: Color(0xFFC9A84C)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final a = _appointments[i];
                    final service = a['services'];
                    final status = a['status'];
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
                              color: const Color(0xFFC9A84C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: Color(0xFFC9A84C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service?['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1208),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${a['date']} · ${a['time'].toString().substring(0, 5)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A8A6A),
                                  ),
                                ),
                                Text(
                                  '₺${service?['price']} · ${service?['duration_minutes']} dk',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9A8A6A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'confirmed'
                                  ? const Color(0xFFEDF7EE)
                                  : status == 'cancelled'
                                      ? const Color(0xFFFDECEA)
                                      : const Color(0xFFFDF4E3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status == 'confirmed'
                                  ? 'Onaylı'
                                  : status == 'cancelled'
                                      ? 'İptal'
                                      : 'Bekliyor',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: status == 'confirmed'
                                    ? const Color(0xFF2A6A2A)
                                    : status == 'cancelled'
                                        ? const Color(0xFF8A2A2A)
                                        : const Color(0xFF8A5A10),
                              ),
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

class _ServicesTab extends StatefulWidget {
  const _ServicesTab();

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tümü';
  List<String> _categories = ['Tümü'];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await SupabaseService.getServices();
    final categories = ['Tümü'];
    for (final s in services) {
      if (s['category'] != null && !categories.contains(s['category'])) {
        categories.add(s['category']);
      }
    }
    setState(() {
      _services = services;
      _categories = categories;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedCategory == 'Tümü') return _services;
    return _services.where((s) => s['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Hizmetlerimiz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1A1208) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFFE8E0D0),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFF9A8A6A),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredServices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final s = _filteredServices[i];
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
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A84C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.spa_outlined, color: Color(0xFFC9A84C), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
                                  const SizedBox(height: 4),
                                  Text(s['description'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('₺${s['price']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C))),
                                      const Text(' · ', style: TextStyle(color: Color(0xFF9A8A6A))),
                                      Text('${s['duration_minutes']} dk', style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1208),
                                foregroundColor: const Color(0xFFC9A84C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Randevu Al', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  Map<String, dynamic>? _userData;
  int _loyaltyPoints = 0;
  int _totalAppointments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      final userData = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final points = await SupabaseService.getLoyaltyPoints();

      final appointments = await Supabase.instance.client
          .from('appointments')
          .select()
          .eq('user_id', user.id);

      setState(() {
        _userData = userData;
        _loyaltyPoints = points;
        _totalAppointments = (appointments as List).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = _userData?['full_name'] ?? user?.email ?? 'Kullanıcı';
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Üst profil alanı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                    color: const Color(0xFF1A1208),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC9A84C),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1208),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFC9A84C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A8A6A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // İstatistikler
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatItem(
                              value: '$_totalAppointments',
                              label: 'Randevu',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFF3A2E1A),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            _StatItem(
                              value: '$_loyaltyPoints',
                              label: 'Puan',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menü öğeleri
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Randevularım',
                          onTap: () {},
                        ),
                        _MenuTile(
                          icon: Icons.star_outline,
                          title: 'Sadakat Puanlarım',
                          subtitle: '$_loyaltyPoints puan',
                          onTap: () {},
                        ),
                        _MenuTile(
                          icon: Icons.person_outline,
                          title: 'Bilgilerimi Düzenle',
                          onTap: () {},
                        ),
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Bildirim Ayarları',
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        // Çıkış butonu
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await SupabaseService.signOut();
                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8A2A2A),
                              side: const BorderSide(color: Color(0xFFFDECEA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Çıkış Yap'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC9A84C),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9A8A6A),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E0D0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC9A84C), size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1208),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9A8A6A),
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9A8A6A), size: 18),
        onTap: onTap,
      ),
    );
  }
}