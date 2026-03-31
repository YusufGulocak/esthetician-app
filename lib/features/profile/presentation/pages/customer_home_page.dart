import 'package:flutter/material.dart';

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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sadakat Puanınız', style: TextStyle(fontSize: 11, color: Color(0xFF9A8A6A))),
                            Text('320 Puan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFC9A84C))),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1208),
                        foregroundColor: const Color(0xFFC9A84C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Randevularım', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
            SizedBox(height: 20),
            Center(child: Text('Henüz randevunuz yok', style: TextStyle(color: Color(0xFF9A8A6A)))),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hizmetlerimiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
            SizedBox(height: 20),
            Center(child: Text('Yakında...', style: TextStyle(color: Color(0xFF9A8A6A)))),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profilim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF1A1208))),
            SizedBox(height: 20),
            Center(child: Text('Yakında...', style: TextStyle(color: Color(0xFF9A8A6A)))),
          ],
        ),
      ),
    );
  }
}