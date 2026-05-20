import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../appointments/presentation/pages/book_appointment_page.dart';
import '../../../loyalty/presentation/pages/rewards_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _gold = Color(0xFFC9A84C);
const _dark = Color(0xFF1C1A16);
const _muted = Color(0xFF9A8A6A);
const _border = Color(0xFFE8DFC8);
// ─────────────────────────────────────────────────────────────────────────────

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        const _HomeTab(),
        const _AppointmentsTab(),
        const _ServicesTab(),
        _ProfileTab(onGoToAppointments: () => setState(() => _selectedIndex = 1)),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _gold,
          unselectedItemColor: const Color(0xFFB0A080),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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

// ─── Marble CustomPainter ─────────────────────────────────────────────────────
class _MarblePainter extends CustomPainter {
  const _MarblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Soft gold glow blobs
    void glow(Offset c, double r, double a) {
      canvas.drawCircle(
        c, r,
        Paint()
          ..color = _gold.withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }

    glow(Offset(size.width * 0.88, size.height * 0.12), 70, 0.18);
    glow(Offset(size.width * 0.08, size.height * 0.88), 50, 0.12);
    glow(Offset(size.width * 0.5, size.height * 0.5), 35, 0.06);

    // Thin gold veins
    void vein(List<Offset> pts, double alpha, double width) {
      if (pts.length < 4) return;
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      path.cubicTo(pts[1].dx, pts[1].dy, pts[2].dx, pts[2].dy, pts[3].dx, pts[3].dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = _gold.withValues(alpha: alpha)
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    vein([
      Offset(0, size.height * 0.38),
      Offset(size.width * 0.28, size.height * 0.08),
      Offset(size.width * 0.62, size.height * 0.58),
      Offset(size.width, size.height * 0.28),
    ], 0.22, 1.2);

    vein([
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.58, size.height * 0.38),
      Offset(size.width * 0.78, size.height * 0.28),
      Offset(size.width, size.height * 0.75),
    ], 0.13, 0.8);

    vein([
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.22, size.height * 0.62),
      Offset(size.width * 0.45, size.height * 0.88),
      Offset(size.width * 0.72, size.height * 0.78),
    ], 0.10, 0.7);
  }

  @override
  bool shouldRepaint(_MarblePainter old) => false;
}
// ─────────────────────────────────────────────────────────────────────────────

// Shared marble header shell
Widget _marbleHeader({required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF4EDD8)],
      ),
      border: Border(bottom: BorderSide(color: _border, width: 0.5)),
    ),
    child: Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _MarblePainter())),
        child,
      ],
    ),
  );
}

// Fallback icon box for service list thumbnails
Widget _svcIconBox() => Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.spa_outlined, color: _gold, size: 24),
    );

// Shared card decoration
BoxDecoration _cardDecor({double radius = 16}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
    );

// ─── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _loyaltyPoints = 0;
  Map<String, dynamic>? _nextAppointment;
  List<Map<String, dynamic>> _services = [];
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = SupabaseService.currentUser;
    final points = await SupabaseService.getLoyaltyPoints();
    final nextAppointment = await SupabaseService.getNextAppointment();
    final services = await SupabaseService.getServices();

    String name = '';
    if (user != null) {
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = userData?['full_name'] ?? user.email ?? '';
      } catch (_) {
        name = user.email ?? '';
      }
    }

    if (!mounted) return;
    setState(() {
      _loyaltyPoints = points;
      _nextAppointment = nextAppointment;
      _services = services.take(4).toList();
      _userName = name.split(' ').first;
    });
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    const months = ['', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[m]}';
  }

  @override
  Widget build(BuildContext context) {
    final status = _nextAppointment?['status'] as String?;
    final statusBg = status == 'confirmed' ? const Color(0xFFEDF7EE) : const Color(0xFFFDF4E3);
    final statusFg = status == 'confirmed' ? const Color(0xFF2A6A2A) : const Color(0xFF8A5A10);
    final statusLabel = status == 'confirmed' ? 'Onaylı' : 'Bekliyor';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Marble header ──
            _marbleHeader(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName.isEmpty ? 'Merhaba 👋' : 'Merhaba, $_userName 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Bugün kendinize iyi bakın',
                                style: TextStyle(fontSize: 13, color: _muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(alpha: 0.40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Loyalty card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _gold.withValues(alpha: 0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star_rounded, color: _gold, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sadakat Puanınız',
                                  style: TextStyle(fontSize: 11, color: _muted)),
                              Text(
                                '$_loyaltyPoints Puan',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _gold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RewardsPage()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Ödülleri Gör',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yaklaşan Randevunuz',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
                  const SizedBox(height: 12),

                  // Appointment card
                  if (_nextAppointment == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecor(),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F0E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month_outlined,
                                color: Color(0xFFB0A080), size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text('Yaklaşan randevunuz yok',
                                style: TextStyle(fontSize: 13, color: _muted)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
                            child: const Text('Al →',
                                style: TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecor(),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.spa_outlined, color: _gold, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nextAppointment!['services']?['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _dark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(_nextAppointment!['date'])} · ${(_nextAppointment!['time'] as String).substring(0, 5)}',
                                  style: const TextStyle(fontSize: 12, color: _muted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusBg, borderRadius: BorderRadius.circular(8)),
                            child: Text(statusLabel,
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600, color: statusFg)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),
                  const Text('Hizmetlerimiz',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
                  const SizedBox(height: 12),
                  if (_services.isNotEmpty)
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _services.length,
                      itemBuilder: (_, i) {
                        final s = _services[i];
                        return _ServiceCard(
                          name: s['name'] ?? '',
                          price: '₺${s['price']}',
                          duration: '${s['duration_minutes']} dk',
                          imageUrl: s['image_url'] as String?,
                        );
                      },
                    ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: _gold.withValues(alpha: 0.40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Randevu Al',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
  final String? imageUrl;

  const _ServiceCard({
    required this.name,
    required this.price,
    required this.duration,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecor(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _iconBox(),
                  )
                : _iconBox(),
          ),
          const Spacer(),
          Text(name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(price,
                  style: const TextStyle(fontSize: 12, color: _gold, fontWeight: FontWeight.w600)),
              const Text(' · ', style: TextStyle(color: _muted, fontSize: 12)),
              Text(duration, style: const TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBox() => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.spa_outlined, color: _gold, size: 18),
      );
}

// ─── Appointments Tab ─────────────────────────────────────────────────────────
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini header
          _marbleHeader(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  const Text('Randevularım',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadAppointments,
                    child: const Icon(Icons.refresh, color: _gold, size: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Expanded(
                child: Center(child: CircularProgressIndicator(color: _gold)))
          else if (_appointments.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_month_outlined, color: _gold, size: 34),
                    ),
                    const SizedBox(height: 16),
                    const Text('Henüz randevunuz yok',
                        style: TextStyle(color: _muted, fontSize: 14)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
                      child: const Text('Randevu Al →',
                          style: TextStyle(color: _gold, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _appointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final a = _appointments[i];
                  final service = a['services'];
                  final status = a['status'];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecor(),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.spa_outlined, color: _gold, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service?['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: _dark)),
                              const SizedBox(height: 4),
                              Text(
                                '${a['date']} · ${a['time'].toString().substring(0, 5)}',
                                style: const TextStyle(fontSize: 12, color: _muted),
                              ),
                              Text(
                                '₺${service?['price']} · ${service?['duration_minutes']} dk',
                                style: const TextStyle(fontSize: 11, color: _muted),
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
                              fontWeight: FontWeight.w600,
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
    );
  }
}

// ─── Services Tab ─────────────────────────────────────────────────────────────
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
    final cats = ['Tümü'];
    for (final s in services) {
      if (s['category'] != null && !cats.contains(s['category'])) {
        cats.add(s['category']);
      }
    }
    setState(() {
      _services = services;
      _categories = cats;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 'Tümü') return _services;
    return _services.where((s) => s['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _marbleHeader(
            child: const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Text('Hizmetlerimiz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _dark)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? _gold : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? _gold : _border),
                      boxShadow: sel
                          ? [BoxShadow(color: _gold.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Text(cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _muted,
                        )),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _gold))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      final sImgUrl = s['image_url'] as String?;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecor(),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: sImgUrl != null && sImgUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: sImgUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => _svcIconBox(),
                                    )
                                  : _svcIconBox(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'],
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w600, color: _dark)),
                                  const SizedBox(height: 3),
                                  Text(s['description'] ?? '',
                                      style: const TextStyle(fontSize: 12, color: _muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('₺${s['price']}',
                                          style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w700, color: _gold)),
                                      const Text(' · ', style: TextStyle(color: _muted)),
                                      Text('${s['duration_minutes']} dk',
                                          style: const TextStyle(fontSize: 12, color: _muted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              ),
                              child: const Text('Randevu Al',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  final VoidCallback? onGoToAppointments;
  const _ProfileTab({this.onGoToAppointments});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  Map<String, dynamic>? _userData;
  int _loyaltyPoints = 0;
  int _totalAppointments = 0;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

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
          .from('users').select().eq('id', user.id).maybeSingle();
      final points = await SupabaseService.getLoyaltyPoints();
      final appts = await Supabase.instance.client
          .from('appointments').select().eq('user_id', user.id);
      setState(() {
        _userData = userData;
        _loyaltyPoints = points;
        _totalAppointments = (appts as List).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: _gold),
              title: const Text('Kamera', style: TextStyle(fontSize: 14, color: _dark)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _gold),
              title: const Text('Galeri', style: TextStyle(fontSize: 14, color: _dark)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 512);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await SupabaseService.uploadAvatar(File(picked.path));
      await SupabaseService.updateProfile(
        fullName: _userData?['full_name'] ?? '',
        phone: _userData?['phone'] ?? '',
        avatarUrl: url,
      );
      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: const Color(0xFF8A2A2A)),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showEditProfileSheet(BuildContext ctx) {
    final nameCtrl = TextEditingController(text: _userData?['full_name'] ?? '');
    final phoneCtrl = TextEditingController(text: _userData?['phone'] ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Bilgilerimi Düzenle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    icon: const Icon(Icons.close, size: 20, color: _muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(nameCtrl, 'Ad Soyad', Icons.person_outline),
              const SizedBox(height: 12),
              _field(phoneCtrl, 'Telefon', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty) return;
                          setSheet(() => saving = true);
                          try {
                            await SupabaseService.updateProfile(
                              fullName: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            );
                            if (!sheetCtx.mounted) return;
                            Navigator.pop(sheetCtx);
                            _loadProfile();
                          } finally {
                            if (sheetCtx.mounted) setSheet(() => saving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _muted),
        prefixIcon: Icon(icon, color: _muted, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8F6F2),
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

  void _showNotifications(BuildContext ctx) {
    bool reminder = true;
    bool promos = false;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, set) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bildirim Ayarları',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Randevu Hatırlatıcısı',
                    style: TextStyle(fontSize: 14, color: _dark)),
                subtitle: const Text('Randevudan 1 saat önce',
                    style: TextStyle(fontSize: 12, color: _muted)),
                value: reminder,
                activeThumbColor: _gold,
                activeTrackColor: _gold.withValues(alpha: 0.4),
                onChanged: (v) => set(() => reminder = v),
              ),
              const Divider(height: 1, color: _border),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kampanya ve Fırsatlar',
                    style: TextStyle(fontSize: 14, color: _dark)),
                subtitle: const Text('Özel teklifler ve indirimler',
                    style: TextStyle(fontSize: 12, color: _muted)),
                value: promos,
                activeThumbColor: _gold,
                activeTrackColor: _gold.withValues(alpha: 0.4),
                onChanged: (v) => set(() => promos = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final name = _userData?['full_name'] ?? user?.email ?? 'Kullanıcı';
    final initials =
        name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final avatarUrl = _userData?['avatar_url'] as String?;

    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Marble profile header ──
                  _marbleHeader(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadPhoto,
                            child: Stack(
                              children: [
                                Container(
                                  width: 84, height: 84,
                                  decoration: BoxDecoration(
                                    color: _gold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: 0.40),
                                        blurRadius: 16,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: _isUploadingPhoto
                                      ? const Center(
                                          child: SizedBox(
                                              width: 24, height: 24,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: Colors.white)))
                                      : avatarUrl != null && avatarUrl.isNotEmpty
                                          ? ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: avatarUrl,
                                                width: 84, height: 84,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => Center(
                                                    child: Text(initials,
                                                        style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white))),
                                                errorWidget: (_, __, ___) => Center(
                                                    child: Text(initials,
                                                        style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white))),
                                              ),
                                            )
                                          : Center(
                                              child: Text(initials,
                                                  style: const TextStyle(
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white))),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _gold, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.10),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 14, color: _gold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '',
                              style: const TextStyle(fontSize: 12, color: _muted)),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _gold.withValues(alpha: 0.20)),
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withValues(alpha: 0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StatItem(value: '$_totalAppointments', label: 'Randevu'),
                                Container(
                                  width: 1, height: 32,
                                  color: _border,
                                  margin: const EdgeInsets.symmetric(horizontal: 28),
                                ),
                                _StatItem(value: '$_loyaltyPoints', label: 'Puan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Menu ──
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Randevularım',
                          onTap: () => widget.onGoToAppointments?.call(),
                        ),
                        _MenuTile(
                          icon: Icons.star_outline,
                          title: 'Sadakat Puanlarım',
                          subtitle: '$_loyaltyPoints puan',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RewardsPage())),
                        ),
                        _MenuTile(
                          icon: Icons.person_outline,
                          title: 'Bilgilerimi Düzenle',
                          onTap: () => _showEditProfileSheet(context),
                        ),
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Bildirim Ayarları',
                          onTap: () => _showNotifications(context),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity, height: 48,
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
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Çıkış Yap',
                                style: TextStyle(fontWeight: FontWeight.w600)),
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
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _gold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecor(radius: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _gold, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _dark)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: _muted))
            : null,
        trailing: const Icon(Icons.chevron_right, color: _muted, size: 18),
        onTap: onTap,
      ),
    );
  }
}
