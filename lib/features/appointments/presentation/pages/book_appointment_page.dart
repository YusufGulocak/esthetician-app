import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_service.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<Map<String, dynamic>> _services = [];
  Map<String, dynamic>? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isServicesLoading = true;

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final services = await SupabaseService.getServices();
    setState(() {
      _services = services;
      _isServicesLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC9A84C),
              onPrimary: Color(0xFF1A1208),
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _bookAppointment() async {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen hizmet, tarih ve saat seçin'),
          backgroundColor: Color(0xFF8A2A2A),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final date =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Aynı gün onaylı randevu var mı kontrol et
      final existing = await Supabase.instance.client
          .from('appointments')
          .select('id')
          .eq('user_id', SupabaseService.currentUser!.id)
          .eq('date', date)
          .eq('status', 'confirmed')
          .limit(1);

      if (existing.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu tarihte zaten onaylı bir randevunuz var'),
            backgroundColor: Color(0xFF8A2A2A),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await SupabaseService.createAppointment(
        serviceId: _selectedService!['id'],
        date: date,
        time: _selectedTime!,
        notes: _notesController.text,
        customerName: SupabaseService.currentUser?.email ?? '',
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF2A6A2A)),
              SizedBox(width: 8),
              Text('Randevu Alındı!', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hizmet: ${_selectedService!['name']}'),
              const SizedBox(height: 4),
              Text('Tarih: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'),
              const SizedBox(height: 4),
              Text('Saat: $_selectedTime'),
              const SizedBox(height: 8),
              const Text(
                'Randevunuz onay bekliyor. Onaylandığında bildirim alacaksınız.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A84C),
                foregroundColor: const Color(0xFF1A1208),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: const Color(0xFF8A2A2A),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text(
          'Randevu Al',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC9A84C)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hizmet seçimi
            const Text(
              'Hizmet Seçin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1208),
              ),
            ),
            const SizedBox(height: 12),
            _isServicesLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _services.map((s) {
                      final isSelected = _selectedService?['id'] == s['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedService = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1A1208) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFFE8E0D0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFF1A1208),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₺${s['price']} · ${s['duration_minutes']} dk',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? const Color(0xFF9A8A6A) : const Color(0xFF9A8A6A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            // Tarih seçimi
            const Text(
              'Tarih Seçin',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E0D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFFC9A84C), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Tarih seçin'
                          : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null ? const Color(0xFF9A8A6A) : const Color(0xFF1A1208),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Color(0xFF9A8A6A)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Saat seçimi
            const Text(
              'Saat Seçin',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC9A84C) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFFE8E0D0),
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? const Color(0xFF1A1208) : const Color(0xFF9A8A6A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notlar
            const Text(
              'Notlar (isteğe bağlı)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1208)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1208)),
              decoration: InputDecoration(
                hintText: 'Eklemek istediğiniz notlar...',
                hintStyle: const TextStyle(color: Color(0xFF9A8A6A), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
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
              ),
            ),
            const SizedBox(height: 32),

            // Randevu al butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1208),
                  foregroundColor: const Color(0xFFC9A84C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC9A84C)),
                      )
                    : const Text(
                        'Randevuyu Onayla',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}