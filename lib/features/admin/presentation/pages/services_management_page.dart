import 'package:flutter/material.dart';
import '../../../../core/network/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> _deleteService(String id) async {
    await Supabase.instance.client
        .from('services')
        .update({'is_active': false})
        .eq('id', id);
    _loadServices();
  }

  void _showAddEditDialog({Map<String, dynamic>? service}) {
    final nameController = TextEditingController(text: service?['name'] ?? '');
    final descController = TextEditingController(text: service?['description'] ?? '');
    final priceController = TextEditingController(text: service?['price']?.toString() ?? '');
    final durationController = TextEditingController(text: service?['duration_minutes']?.toString() ?? '');
    final categoryController = TextEditingController(text: service?['category'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          service == null ? 'Yeni Hizmet' : 'Hizmet Düzenle',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameController, 'Hizmet Adı'),
              const SizedBox(height: 12),
              _buildField(descController, 'Açıklama'),
              const SizedBox(height: 12),
              _buildField(priceController, 'Fiyat (₺)', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildField(durationController, 'Süre (dakika)', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildField(categoryController, 'Kategori'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Color(0xFF9A8A6A))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (service == null) {
                await SupabaseService.addService(
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  durationMinutes: int.tryParse(durationController.text) ?? 0,
                  category: categoryController.text,
                );
              } else {
                await SupabaseService.updateService(
                  id: service['id'],
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  durationMinutes: int.tryParse(durationController.text) ?? 0,
                  category: categoryController.text,
                );
              }
              _loadServices();
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
    );
  }

  Widget _buildField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
        filled: true,
        fillColor: const Color(0xFFFAF7F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text(
          'Hizmet Yönetimi',
          style: TextStyle(color: Color(0xFFC9A84C), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC9A84C)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFC9A84C)),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : _services.isEmpty
              ? const Center(
                  child: Text('Henüz hizmet yok', style: TextStyle(color: Color(0xFF9A8A6A))),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = _services[i];
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
                            child: const Icon(Icons.spa_outlined, color: Color(0xFFC9A84C), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1208),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₺${s['price']} · ${s['duration_minutes']} dk · ${s['category'] ?? ''}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF9A8A6A)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFFC9A84C), size: 18),
                            onPressed: () => _showAddEditDialog(service: s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFF8A2A2A), size: 18),
                            onPressed: () => _deleteService(s['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}