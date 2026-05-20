import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_service.dart';

const _gold = Color(0xFFC9A84C);
const _dark = Color(0xFF1C1A16);
const _muted = Color(0xFF9A8A6A);
const _border = Color(0xFFE8DFC8);

class ServicesManagementPage extends StatefulWidget {
  const ServicesManagementPage({super.key});

  @override
  State<ServicesManagementPage> createState() => _ServicesManagementPageState();
}

class _ServicesManagementPageState extends State<ServicesManagementPage> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    final services = await SupabaseService.getServices();
    setState(() {
      _services = services;
      _isLoading = false;
    });
  }

  Future<void> _deactivateService(String id) async {
    await Supabase.instance.client
        .from('services')
        .update({'is_active': false})
        .eq('id', id);
    _loadServices();
  }

  void _showServiceSheet({Map<String, dynamic>? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceFormSheet(
        service: service,
        onSaved: _loadServices,
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
          'Hizmet Yönetimi',
          style: TextStyle(color: _gold, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _gold),
            onPressed: () => _showServiceSheet(),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _services.isEmpty
              ? const Center(
                  child: Text('Henüz hizmet yok', style: TextStyle(color: _muted)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = _services[i];
                    final imgUrl = s['image_url'] as String?;
                    return Container(
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
                          // Thumbnail
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(14)),
                            child: imgUrl != null && imgUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _placeholderBox(),
                                  )
                                : _placeholderBox(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _dark)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₺${s['price']} · ${s['duration_minutes']} dk'
                                    '${s['category'] != null ? ' · ${s['category']}' : ''}',
                                    style: const TextStyle(
                                        fontSize: 12, color: _muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: _gold, size: 18),
                            onPressed: () => _showServiceSheet(service: s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFF8A2A2A), size: 18),
                            onPressed: () => _deactivateService(s['id']),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      width: 72,
      height: 72,
      color: _gold.withValues(alpha: 0.08),
      child: const Icon(Icons.spa_outlined, color: _gold, size: 24),
    );
  }
}

// ─── Service Form Sheet ───────────────────────────────────────────────────────
class _ServiceFormSheet extends StatefulWidget {
  final Map<String, dynamic>? service;
  final VoidCallback onSaved;

  const _ServiceFormSheet({this.service, required this.onSaved});

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _duration;
  late final TextEditingController _category;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _name = TextEditingController(text: s?['name'] ?? '');
    _desc = TextEditingController(text: s?['description'] ?? '');
    _price = TextEditingController(text: s?['price']?.toString() ?? '');
    _duration =
        TextEditingController(text: s?['duration_minutes']?.toString() ?? '');
    _category = TextEditingController(text: s?['category'] ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _duration.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 900);
    if (picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hizmet adı zorunludur'),
            backgroundColor: Color(0xFF8A2A2A)),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final String serviceId;

      if (widget.service == null) {
        serviceId = await SupabaseService.addService(
          name: _name.text.trim(),
          description: _desc.text.trim(),
          price: double.tryParse(_price.text) ?? 0,
          durationMinutes: int.tryParse(_duration.text) ?? 0,
          category: _category.text.trim(),
        );
      } else {
        serviceId = widget.service!['id'] as String;
        await SupabaseService.updateService(
          id: serviceId,
          name: _name.text.trim(),
          description: _desc.text.trim(),
          price: double.tryParse(_price.text) ?? 0,
          durationMinutes: int.tryParse(_duration.text) ?? 0,
          category: _category.text.trim(),
        );
      }

      if (_imageFile != null) {
        final url =
            await SupabaseService.uploadServiceImage(_imageFile!, serviceId);
        await SupabaseService.updateServiceImage(serviceId, url);
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: const Color(0xFF8A2A2A)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = widget.service?['image_url'] as String?;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: _border, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Row(
              children: [
                Text(
                  widget.service == null ? 'Yeni Hizmet' : 'Hizmet Düzenle',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dark),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: _muted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Fotoğraf alanı ──
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imageFile!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    : (existingUrl != null && existingUrl.isNotEmpty)
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: existingUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.30),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined,
                                          color: Colors.white, size: 28),
                                      SizedBox(height: 6),
                                      Text('Değiştir',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: _gold, size: 36),
                              SizedBox(height: 8),
                              Text('Fotoğraf Ekle',
                                  style: TextStyle(
                                      fontSize: 13, color: _muted)),
                              SizedBox(height: 2),
                              Text('Galeriden seç',
                                  style: TextStyle(
                                      fontSize: 11, color: _border)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Form alanları ──
            _field(_name, 'Hizmet Adı *'),
            const SizedBox(height: 10),
            _field(_desc, 'Açıklama'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _field(_price, 'Fiyat (₺)',
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(
                    child: _field(_duration, 'Süre (dk)',
                        keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 10),
            _field(_category, 'Kategori'),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: _gold.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Kaydet',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
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
}
