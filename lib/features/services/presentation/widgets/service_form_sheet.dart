import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../data/models/service_model.dart';
import '../bloc/services_bloc.dart';

class ServiceFormSheet extends StatefulWidget {
  final ServiceModel? service;
  // ✅ Categories passed from the parent page (already loaded there)
  final List<Map<String, String>>? categories;

  const ServiceFormSheet({super.key, this.service, this.categories});

  @override
  State<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<ServiceFormSheet> {
  final _nameCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  String _category = 'consultation';
  String _providerId = '';
  String _providerName = '';
  bool _isAvailable = true;
  bool _loadingProviders = false;
  bool _loadingCategories = false;
  List<Map<String, String>> _providers = [];
  List<Map<String, String>> _localCats = [];

  bool get _isEditing => widget.service != null;

  // ✅ Static fallback — used only if nothing was passed in AND
  // Firestore has no categories saved yet
  static const _staticCategories = <Map<String, String>>[
    {'value': 'consultation', 'name': 'Consultation'},
    {'value': 'radiology', 'name': 'Radiology'},
    {'value': 'lab', 'name': 'Lab'},
    {'value': 'pharmacy', 'name': 'Pharmacy'},
    {'value': 'dental', 'name': 'Dental'},
    {'value': 'physiotherapy', 'name': 'Physiotherapy'},
    {'value': 'blood_pressure', 'name': 'Blood Pressure'},
    {'value': 'blood_sugar', 'name': 'Blood Sugar'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameCtrl.text = s?.name ?? '';
    _discountCtrl.text = '${s?.discountPercent ?? 20}';
    _descCtrl.text = s?.description ?? '';
    _imageCtrl.text = s?.imageUrl ?? '';
    _category = s?.category ?? 'consultation';
    _providerId = s?.providerId ?? '';
    _providerName = s?.providerName ?? '';
    _isAvailable = s?.isAvailable ?? true;

    // ✅ Use categories passed from parent if available,
    // otherwise load them ourselves from Firestore
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _localCats = widget.categories!;
      if (!_localCats.any((c) => c['value'] == _category)) {
        _category = _localCats.first['value'] ?? 'consultation';
      }
    } else {
      _loadCategories();
    }

    _loadProviders();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  // ✅ Fallback loader — only runs if parent didn't pass categories
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('service_categories')
          .where('isActive', isEqualTo: true)
          .get();

      if (!mounted) return;
      if (snap.docs.isEmpty) {
        setState(() {
          _localCats = List.from(_staticCategories);
          _loadingCategories = false;
        });
        return;
      }

      final cats = snap.docs
          .map(
            (doc) => {
              'value': doc.data()['value'] as String? ?? doc.id,
              'name': doc.data()['name'] as String? ?? 'Unknown',
              'order': (doc.data()['order'] as int? ?? 99).toString(),
            },
          )
          .toList();

      cats.sort(
        (a, b) => int.parse(a['order']!).compareTo(int.parse(b['order']!)),
      );

      setState(() {
        _localCats = cats
            .map((c) => {'value': c['value']!, 'name': c['name']!})
            .toList();
        _loadingCategories = false;

        if (!_localCats.any((c) => c['value'] == _category)) {
          _category = _localCats.first['value'] ?? 'consultation';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localCats = List.from(_staticCategories);
        _loadingCategories = false;
      });
    }
  }

  Future<void> _loadProviders() async {
    setState(() => _loadingProviders = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('providers')
          .where('isActive', isEqualTo: true)
          .get();

      if (!mounted) return;
      final loadedProviders = snap.docs.map((doc) {
        final data = doc.data();
        // فحص أكثر من مفتاح محتمل للاسم في فايربيز لتجنب أي اختلاف في الموديل
        final name =
            (data['name'] ?? data['providerName'] ?? data['title'] ?? '')
                .toString();
        final phone = (data['phoneNumber'] ?? data['phone'] ?? '').toString();
        String normalize(String value) =>
            value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        final nameKey = normalize(name);
        final area = (data['area'] ?? '').toString().trim();
        final addressKey = normalize((data['address'] ?? '').toString());
        final phoneKey = phone.replaceAll(RegExp(r'\D'), '');
        final locationKey = addressKey.isNotEmpty ? addressKey : phoneKey;
        return {
          'id': doc.id,
          'key': nameKey.isNotEmpty && locationKey.isNotEmpty
              ? '$nameKey|${normalize(area)}|$locationKey'
              : doc.id,
          'area': area,
          'name': name.trim().isEmpty
              ? 'Unnamed Provider (${phone.isNotEmpty ? phone : doc.id})'
              : name.trim(),
        };
      }).toList();

      // Keep one choice per location for new services. Preserve the linked
      // record while editing an existing service, even when it is a duplicate.
      final uniqueProviders = <String, Map<String, String>>{};
      for (final provider in loadedProviders) {
        final key = provider['key']!;
        if (!uniqueProviders.containsKey(key) ||
            provider['id'] == _providerId) {
          uniqueProviders[key] = provider;
        }
      }
      final pickerProviders = uniqueProviders.values.toList();
      pickerProviders.sort(
        (a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''),
      );

      setState(() {
        _providers = pickerProviders;
        _loadingProviders = false;

        // تحديث اسم المزود تلقائياً لو الخدمة قديمة والاسم القديم كان محفوظ غلط
        if (_providerId.isNotEmpty) {
          try {
            final existingP = _providers.firstWhere(
              (p) => p['id'] == _providerId,
            );
            _providerName = existingP['name'] ?? _providerName;
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('Error loading providers: $e');
      if (!mounted) return;
      setState(() => _loadingProviders = false);
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) setState(() => _selectedImageBytes = bytes);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    if (_providerId.isEmpty || _isUploading) return;

    var imageUrl = _imageCtrl.text.trim();
    if (_selectedImageBytes != null) {
      setState(() => _isUploading = true);
      try {
        final name = 'service_${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = FirebaseStorage.instance.ref('services/$name');
        await ref.putData(_selectedImageBytes!);
        imageUrl = await ref.getDownloadURL();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $error')));
        setState(() => _isUploading = false);
        return;
      }
    }
    if (!mounted) return;

    final service = (widget.service ?? ServiceModel.empty()).copyWithFields(
      name: _nameCtrl.text.trim(),
      category: _category,
      providerId: _providerId,
      providerName: _providerName,
      discountPercent: int.tryParse(_discountCtrl.text) ?? 20,
      isAvailable: _isAvailable,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageUrl: imageUrl,
      clearImageUrl: imageUrl.isEmpty,
    );

    if (_isEditing) {
      context.read<ServicesBloc>().add(ServiceUpdateRequested(service));
    } else {
      context.read<ServicesBloc>().add(ServiceAddRequested(service));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _localCats.isNotEmpty ? _localCats : _staticCategories;

    // ✅ Guard against a stale category value that no longer exists
    final catValue = categories.any((c) => c['value'] == _category)
        ? _category
        : categories.first['value']!;

    return Container(
      width: 650,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85, // أقصى طول
      ),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Service' : 'Add Service',
                    style: DTextStyles.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Provider (required)
                Text('Provider *', style: DTextStyles.label),
                const SizedBox(height: 6),
                _loadingProviders
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: DColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue:
                            _providers.any((p) => p['id'] == _providerId)
                            ? _providerId
                            : null,
                        hint: const Text(
                          'Select Provider',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChanged: (v) {
                          if (v == null) return;
                          final provider = _providers.firstWhere(
                            (p) => p['id'] == v,
                          );
                          setState(() {
                            _providerId = v;
                            _providerName = provider['name'] ?? '';
                          });
                        },
                        decoration: const InputDecoration(),
                        items: _providers
                            .map(
                              (p) => DropdownMenuItem(
                                value: p['id'],
                                child: Text(
                                  [p['name'], p['area']]
                                      .where(
                                        (part) =>
                                            part != null && part.isNotEmpty,
                                      )
                                      .join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: 16),

                // Service Name
                Text('Service Name *', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Blood Test, X-Ray',
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Category — dynamic dropdown
                Text('Category', style: DTextStyles.label),
                const SizedBox(height: 6),
                _loadingCategories
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: DColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: catValue,
                        onChanged: (v) =>
                            setState(() => _category = v ?? _category),
                        decoration: const InputDecoration(),
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(
                                value: e['value'],
                                child: Text(e['name']!),
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: 16),

                // Discount
                Text('Discount %', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '20',
                    suffixText: '%',
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text('Description (optional)', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Additional details...',
                  ),
                ),

                const SizedBox(height: 16),

                Text('Service image (optional)', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _imageCtrl,
                  onChanged: (_) {
                    if (_selectedImageBytes != null) {
                      setState(() => _selectedImageBytes = null);
                    }
                  },
                  decoration: const InputDecoration(hintText: 'Image URL'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _selectedImageBytes == null
                        ? 'Choose image'
                        : 'Image selected',
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _imageCtrl,
                  builder: (context, value, _) {
                    final bytes = _selectedImageBytes;
                    final url = value.text.trim();
                    if (bytes == null && url.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                DDimens.radiusMD,
                              ),
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: bytes != null
                                    ? Image.memory(bytes, fit: BoxFit.cover)
                                    : Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.broken_image_outlined,
                                          color: DColors.textSecondary,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton.filledTonal(
                                tooltip: 'Remove image',
                                onPressed: () => setState(() {
                                  _selectedImageBytes = null;
                                  _imageCtrl.clear();
                                }),
                                icon: const Icon(Icons.close, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Available toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DColors.background,
                    borderRadius: BorderRadius.circular(DDimens.radiusMD),
                    border: Border.all(color: DColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available', style: DTextStyles.label),
                            Text(
                              'Show to users in app',
                              style: DTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        onChanged: (v) => setState(() => _isAvailable = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submit,
                    child: Text(
                      _isUploading
                          ? 'Uploading image...'
                          : (_isEditing ? 'Update Service' : 'Add Service'),
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
