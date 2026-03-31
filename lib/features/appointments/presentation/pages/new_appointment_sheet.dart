import 'package:flutter/material.dart';

class NewAppointmentSheet extends StatefulWidget {
  const NewAppointmentSheet({super.key});

  @override
  State<NewAppointmentSheet> createState() => _NewAppointmentSheetState();
}

class _NewAppointmentSheetState extends State<NewAppointmentSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isLoading = false;

  final List<String> _services = [
    'Cilt Bakımı',
    'Kaş Tasarımı',
    'Kalıcı Makyaj',
    'Epilasyon',
    'Saç Bakımı',
    'Makyaj',
  ];

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveAppointment() async {
    if (_nameController.text.isEmpty ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun'),
          backgroundColor: Color(0xFF8A2A2A),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Supabase kayıt buraya gelecek
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu başarıyla oluşturuldu'),
        backgroundColor: Color(0xFF2A6A2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0D0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                const Text(
                  'Yeni Randevu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1208),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9A8A6A),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE8E0D0)),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Müşteri adı
                  _buildLabel('Müşteri Adı *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Ad Soyad',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Telefon
                  _buildLabel('Telefon'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '05xx xxx xx xx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Hizmet seçimi
                  _buildLabel('Hizmet *'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E0D0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedService,
                        hint: const Text(
                          'Hizmet seçin',
                          style: TextStyle(
                            color: Color(0xFF9A8A6A),
                            fontSize: 13,
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF9A8A6A),
                        ),
                        items: _services.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1208),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedService = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarih seçimi
                  _buildLabel('Tarih *'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8E0D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF9A8A6A),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate == null
                                ? 'Tarih seçin'
                                : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedDate == null
                                  ? const Color(0xFF9A8A6A)
                                  : const Color(0xFF1A1208),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saat seçimi
                  _buildLabel('Saat *'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC9A84C)
                                : const Color(0xFFFAF7F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFC9A84C)
                                  : const Color(0xFFE8E0D0),
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1A1208)
                                  : const Color(0xFF9A8A6A),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Notlar
                  _buildLabel('Notlar'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A1208),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Randevu ile ilgili notlar...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9A8A6A),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAF7F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8E0D0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8E0D0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFC9A84C), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Kaydet butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A84C),
                        foregroundColor: const Color(0xFF1A1208),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1A1208),
                              ),
                            )
                          : const Text(
                              'Randevu Oluştur',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1208),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1208)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9A8A6A), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF9A8A6A), size: 18),
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
      ),
    );
  }
}