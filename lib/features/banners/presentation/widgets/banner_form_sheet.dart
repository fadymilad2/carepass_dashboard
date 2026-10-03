import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../data/models/banner_model.dart';
import '../bloc/banners_bloc.dart';

class BannerFormSheet extends StatefulWidget {
  final BannerModel? banner;
  const BannerFormSheet({super.key, this.banner});

  @override
  State<BannerFormSheet> createState() => _BannerFormSheetState();
}

class _BannerFormSheetState extends State<BannerFormSheet> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();

  late String _type;
  late bool _isActive;
  late List<String> _selectedAreas;

  bool _isUploading = false;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.banner != null;

  static const _types = ['general', 'promotional', 'provider'];

  static const _ghanaAreas = [
    'Accra',
    'Kumasi',
    'Tamale',
    'Takoradi',
    'Tema',
    'Cape Coast',
    'Ho',
    'Koforidua',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.banner;
    _titleCtrl.text = b?.title ?? '';
    _subtitleCtrl.text = b?.subtitle ?? '';
    _imageCtrl.text = b?.imageUrl ?? '';
    _discountCtrl.text = b?.discountPercent != null
        ? '${b!.discountPercent}'
        : '';
    _providerCtrl.text = b?.providerName ?? '';
    _type = b?.type ?? 'general';
    _isActive = b?.isActive ?? true;
    _selectedAreas = List<String>.from(b?.areas ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _imageCtrl.dispose();
    _discountCtrl.dispose();
    _providerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() => _selectedImageBytes = bytes);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    setState(() => _isUploading = true);
    String finalImageUrl = _imageCtrl.text.trim();

    if (_selectedImageBytes != null) {
      try {
        final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = FirebaseStorage.instance.ref().child('banners/$fileName');

        final uploadTask = await ref.putData(_selectedImageBytes!);
        finalImageUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image: $e');
        if (!mounted) return;
        setState(() => _isUploading = false);
        return; // توقف لو حصل خطأ في الرفع
      }
    }

    if (!mounted) return;
    final banner = (widget.banner ?? BannerModel.empty()).copyWithFields(
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
      imageUrl: finalImageUrl,
      type: _type,
      discountPercent: int.tryParse(_discountCtrl.text),
      providerName: _providerCtrl.text.trim().isEmpty
          ? null
          : _providerCtrl.text.trim(),
      areas: _selectedAreas,
      isActive: _isActive,
    );

    if (_isEditing) {
      context.read<BannersBloc>().add(BannerUpdateRequested(banner));
    } else {
      context.read<BannersBloc>().add(BannerAddRequested(banner));
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 650, // 👈 1. ضيف عرض ثابت ومناسب لشاشة الويب
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.85, // 👈 2. حدد أقصى طول بدل الطول الإجباري
      ),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Banner' : 'Add Banner',
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

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _L('Banner Title'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Quality Care for Less',
                  ),
                ),

                const SizedBox(height: 16),

                _L('Subtitle'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _subtitleCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Save up to 50% on services',
                  ),
                ),

                const SizedBox(height: 16),

                _L('Banner Image'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: DColors.background,
                      borderRadius: BorderRadius.circular(DDimens.radiusMD),
                      border: Border.all(color: DColors.border),
                    ),
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              DDimens.radiusMD,
                            ),
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : (_imageCtrl.text.isNotEmpty &&
                                  _imageCtrl.text.startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    DDimens.radiusMD,
                                  ),
                                  child: Image.network(
                                    _imageCtrl.text,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: DColors.textSecondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select an image',
                                      style: DTextStyles.bodySmall,
                                    ),
                                  ],
                                )),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Or paste image URL here...',
                    prefixIcon: Icon(Icons.link_outlined, size: 18),
                  ),
                  onChanged: (v) {
                    if (_selectedImageBytes == null) setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                _L('Banner Type'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  onChanged: (v) => setState(() => _type = v!),
                  decoration: const InputDecoration(),
                  items: _types
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t[0].toUpperCase() + t.substring(1)),
                        ),
                      )
                      .toList(),
                ),

                if (_type == 'provider') ...[
                  const SizedBox(height: 16),
                  _L('Provider Name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _providerCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Accra Medical Center',
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _L('Discount % (optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '50',
                    suffixText: '%',
                  ),
                ),

                const SizedBox(height: 16),

                _L('Target Areas (empty = all areas)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ghanaAreas.map((area) {
                    final selected = _selectedAreas.contains(area);
                    return FilterChip(
                      label: Text(area),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        v
                            ? _selectedAreas.add(area)
                            : _selectedAreas.remove(area);
                      }),
                      selectedColor: DColors.primaryLight,
                      checkmarkColor: DColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? DColors.primary : DColors.textPrimary,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: selected ? DColors.primary : DColors.border,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Active toggle
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
                            Text('Active', style: DTextStyles.label),
                            Text(
                              'Show on home screen',
                              style: DTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
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
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isEditing ? 'Update Banner' : 'Add Banner'),
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

class _L extends StatelessWidget {
  final String text;
  const _L(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: DTextStyles.label);
}
