import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';

part '../widgets/settings_page/content_section.dart';
part '../widgets/settings_page/check_limit_row.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _db = FirebaseFirestore.instance;
  final _logoUrlCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _isUploadingLogo = false;
  final ImagePicker _picker = ImagePicker();

  int _bpChecks = 1;
  int _sugarChecks = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final doc = await _db.collection('settings').doc('app_config').get();
      if (!mounted) return;
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _bpChecks = data['bloodPressureChecksPerMonth'] as int? ?? 1;
          _sugarChecks = data['bloodSugarChecksPerMonth'] as int? ?? 1;
          _logoUrlCtrl.text = data['logoUrl'] as String? ?? '';
        });
      }
    } catch (e) {
      debugPrint('Settings load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;

      setState(() => _isUploadingLogo = true);

      final bytes = await image.readAsBytes();
      final fileName = 'app_logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child('settings/$fileName');

      final uploadTask = await ref.putData(bytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      if (!mounted) return;

      setState(() {
        _logoUrlCtrl.text = downloadUrl;
        _isUploadingLogo = false;
      });
      await _saveSettings();
    } catch (e) {
      debugPrint('Error uploading logo: $e');
      if (mounted) {
        setState(() => _isUploadingLogo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading logo: $e'),
            backgroundColor: DColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await _db.collection('settings').doc('app_config').set({
        'bloodPressureChecksPerMonth': _bpChecks,
        'bloodSugarChecksPerMonth': _sugarChecks,
        'logoUrl': _logoUrlCtrl.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved ✅'),
            backgroundColor: DColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: DColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    // ✅ Fix: Column بدون Expanded — الـ shell بتاع الداشبورد هو اللي بيعمل scroll
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Settings', style: DTextStyles.h2),
                    Text(
                      'Configure app behavior',
                      style: DTextStyles.body.copyWith(
                        color: DColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saving || _loading || _isUploadingLogo
                    ? null
                    : _saveSettings,
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Settings'),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 16 : 24),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: DColors.primary),
              ),
            )
          // ✅ Fix: مباشرة بدون Expanded أو SingleChildScrollView
          else ...[
            // ── App Branding ──────────────────────
            SectionCard(
              title: '🎨 App Branding',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DColors.primaryLight,
                      borderRadius: BorderRadius.circular(DDimens.radiusMD),
                      border: Border.all(
                        color: DColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: DColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Set a logo URL to replace the default app icon. '
                            'Use for seasonal events or campaigns. '
                            'Leave empty to use the default logo.',
                            style: DTextStyles.bodySmall.copyWith(
                              color: DColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('App Logo URL', style: DTextStyles.label),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _logoUrlCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'https://example.com/logo.png',
                            prefixIcon: const Icon(
                              Icons.image_outlined,
                              size: 18,
                            ),
                            suffixIcon: _isUploadingLogo
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: DColors.primary,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.upload_file),
                                    color: DColors.primary,
                                    tooltip: 'Upload from device',
                                    onPressed: _pickAndUploadLogo,
                                  ),
                          ),
                        ),
                      ),
                      if (_logoUrlCtrl.text.trim().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(color: DColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.network(
                              _logoUrlCtrl.text.trim(),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: DColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_logoUrlCtrl.text.trim().isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _logoUrlCtrl.clear());
                        _saveSettings();
                      },
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear logo (use default)'),
                      style: TextButton.styleFrom(
                        foregroundColor: DColors.error,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _logoUrlCtrl,
                    builder: (context, val, _) {
                      if (val.text.trim().isEmpty) {
                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: DColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Default logo (heart icon)',
                              style: DTextStyles.bodySmall,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // ── Help Center Content ───────────────
            _ContentSection(
              title: '❓ Help Center — Support Email',
              label: 'Support Email',
              hint: 'support@carepassghana.com',
              maxLines: 1,
              docKey: 'helpCenter.contactEmail',
              onSave: (value) async {
                await _db.collection('settings').doc('app_content').set({
                  'helpCenter': {'contactEmail': value},
                }, SetOptions(merge: true));
              },
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // ── About Content ─────────────────────
            _ContentSection(
              title: '📖 About CarePass — App Description',
              label: 'About Text',
              hint: 'CarePass is a digital healthcare platform...',
              maxLines: 12,
              docKey: 'about.text',
              onSave: (value) async {
                await _db.collection('settings').doc('app_content').set({
                  'about': {'text': value},
                }, SetOptions(merge: true));
              },
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // ── Health Checks ─────────────────────
            SectionCard(
              title: '🩺 Health Check Limits (per month)',
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DColors.infoLight,
                      borderRadius: BorderRadius.circular(DDimens.radiusMD),
                      border: Border.all(
                        color: DColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: DColors.info,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Controls how many free health checks '
                            'a subscriber can use per month.',
                            style: DTextStyles.bodySmall.copyWith(
                              color: DColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CheckLimitRow(
                    icon: Icons.favorite_outlined,
                    label: 'Blood Pressure Check',
                    color: DColors.error,
                    value: _bpChecks,
                    onChanged: (v) => setState(() => _bpChecks = v),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _CheckLimitRow(
                    icon: Icons.water_drop_outlined,
                    label: 'Blood Sugar Check',
                    color: DColors.warning,
                    value: _sugarChecks,
                    onChanged: (v) => setState(() => _sugarChecks = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Editable Content Section
// ─────────────────────────────────────────────
