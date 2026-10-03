import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // ✅ New
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/provider_model.dart';
import '../bloc/providers_bloc.dart';

class ProviderFormSheet extends StatefulWidget {
  final ProviderModel? provider;
  const ProviderFormSheet({super.key, this.provider});

  @override
  State<ProviderFormSheet> createState() => _ProviderFormSheetState();
}

class _ProviderFormSheetState extends State<ProviderFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _servicesCtrl;
  late final TextEditingController _specialityCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _mapsLinkCtrl; // ✅ New

  // Form fields
  late String _type;
  late Set<String> _selectedTypes;
  late String _area;
  String _district = '';
  late bool _isActive;
  late bool _isInNetwork;
  bool _isUploadingImage = false;
  bool _isExtractingLocation = false; // ✅ New

  // ✅ Dynamic data
  List<Map<String, String>> _dynamicTypes = [];
  List<Map<String, dynamic>> _dynamicCities = [];
  bool _typesLoaded = false;
  bool _citiesLoaded = false;

  bool get _isEditing => widget.provider != null;
  bool get _needsSpecialty => _selectedTypes.contains('doctor');

  // ── Fallback lists ──────────────────────────────────────────────────
  static final _fallbackTypes = <Map<String, String>>[
    {'value': 'clinic', 'label': 'Clinic'},
    {'value': 'hospital', 'label': 'Hospital'},
    {'value': 'pharmacy', 'label': 'Pharmacy'},
    {'value': 'lab', 'label': 'Laboratory'},
    {'value': 'dental', 'label': 'Dental'},
    {'value': 'eye_clinic', 'label': 'Eye Clinic'},
    {'value': 'diagnostic', 'label': 'Diagnostic Center'},
    {'value': 'doctor', 'label': 'Doctor'},
  ];

  static final _fallbackCities = <Map<String, dynamic>>[
    {
      'name': 'Accra',
      'areas': [
        'Osu',
        'East Legon',
        'Cantonments',
        'Airport Residential',
        'Spintex',
        'Madina',
        'Adenta',
        'Dansoman',
        'Accra Central',
      ],
    },
    {
      'name': 'Kumasi',
      'areas': ['Bantama', 'Ahodwo', 'Kwadaso', 'Tech', 'Santasi'],
    },
    {
      'name': 'Tema',
      'areas': ['Community 1', 'Community 11', 'Community 25', 'Sakumono'],
    },
    {
      'name': 'Tamale',
      'areas': ['Central', 'Education Ridge', 'Kalpohin'],
    },
    {
      'name': 'Takoradi',
      'areas': ['Market Circle', 'Effiakuma', 'Sekondi'],
    },
  ];

  static const _specialties = [
    'General Practitioner',
    'Cardiologist',
    'Dermatologist',
    'Gynecologist',
    'Neurologist',
    'Ophthalmologist',
    'Orthopedist',
    'Pediatrician',
    'Psychiatrist',
    'Urologist',
    'ENT Specialist',
    'Dentist',
    'Oncologist',
    'Endocrinologist',
  ];

  // ✅ New — regex patterns matching the same coordinate formats the
  // Cloud Function checks server-side. Tried FIRST, locally, with no
  // network call at all — this is what makes "full" Google Maps links
  // (the ones that already show @lat,lng in the address bar) resolve
  // instantly.
  static final _reAt = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
  static final _re3d4d = RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)');
  static final _reQ = RegExp(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)');
  static final _reLL = RegExp(r'[?&]ll=(-?\d+\.\d+),(-?\d+\.\d+)');

  // ── Districts for selected city ─────────────────────────────────────
  List<String> get _districtsForSelectedCity {
    if (_area.isEmpty) return [];
    try {
      final city = _dynamicCities.firstWhere(
        (c) => c['name'] == _area,
        orElse: () => <String, dynamic>{},
      );
      return List<String>.from(city['areas'] as List? ?? []);
    } catch (_) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.provider;

    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _phoneCtrl = TextEditingController(text: p?.phoneNumber ?? '');
    _discountCtrl = TextEditingController(text: '${p?.discountPercent ?? 20}');
    _ratingCtrl = TextEditingController(text: '${p?.rating ?? 4.0}');
    _hoursCtrl = TextEditingController(
      text: p?.workingHours ?? 'Mon - Fri: 9:00 AM - 6:00 PM',
    );
    _specialityCtrl = TextEditingController(text: p?.speciality ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _latCtrl = TextEditingController(text: p?.latitude?.toString() ?? '');
    _lngCtrl = TextEditingController(text: p?.longitude?.toString() ?? '');
    _websiteCtrl = TextEditingController(text: p?.website ?? '');
    _servicesCtrl = TextEditingController(text: p?.services.join(', ') ?? '');
    _mapsLinkCtrl = TextEditingController(); // ✅ New — always starts empty

    _type = p?.type ?? 'clinic';
    _selectedTypes = (p?.providerTypes ?? [_type]).toSet();
    _area = p?.area ?? '';
    _isActive = p?.isActive ?? true;
    _isInNetwork = p?.isInNetwork ?? true;

    _loadTypesAndLocations();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _discountCtrl.dispose();
    _ratingCtrl.dispose();
    _hoursCtrl.dispose();
    _specialityCtrl.dispose();
    _imageCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _websiteCtrl.dispose();
    _servicesCtrl.dispose();
    _mapsLinkCtrl.dispose(); // ✅ New
    super.dispose();
  }

  // ── Load Types + Locations from Firestore ──────────────────────────
  Future<void> _loadTypesAndLocations() async {
    try {
      final db = FirebaseFirestore.instance;

      final results = await Future.wait([
        db
            .collection('provider_types')
            .where('isActive', isEqualTo: true)
            .orderBy('order')
            .get(),
        db.collection('locations').orderBy('order').get(),
      ]);

      final typesSnap = results[0];
      final citiesSnap = results[1];

      final types = typesSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'value': data['value'] as String? ?? doc.id,
          'label': data['name'] as String? ?? doc.id,
        };
      }).toList();

      final cities = citiesSnap.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'name': data['name'] as String? ?? doc.id,
          'areas': List<String>.from(data['areas'] as List? ?? []),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _dynamicTypes = types.isNotEmpty ? types : _fallbackTypes;
        _dynamicCities = cities.isNotEmpty ? cities : _fallbackCities;
        _typesLoaded = true;
        _citiesLoaded = true;

        // Keep saved categories visible even if they were removed from settings.
        for (final type in _selectedTypes) {
          if (!_dynamicTypes.any((item) => item['value'] == type)) {
            _dynamicTypes.add({'value': type, 'label': type});
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dynamicTypes = _fallbackTypes;
        _dynamicCities = _fallbackCities;
        _typesLoaded = true;
        _citiesLoaded = true;
      });
    }
  }

  // ✅ New — tries to pull lat/lng straight out of the pasted text,
  // trying each known Google Maps URL format in turn. No network
  // call — works for "long" links that already contain the
  // coordinates directly.
  Map<String, double>? _extractCoordinatesLocally(String text) {
    for (final re in [_re3d4d, _reAt, _reQ, _reLL]) {
      final m = re.firstMatch(text);
      if (m != null) {
        final lat = double.tryParse(m.group(1)!);
        final lng = double.tryParse(m.group(2)!);
        if (lat != null && lng != null) {
          return {'lat': lat, 'lng': lng};
        }
      }
    }
    return null;
  }

  // ✅ New — main handler for the "Extract" button.
  Future<void> _extractLocationFromLink() async {
    final link = _mapsLinkCtrl.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a Google Maps link first')),
      );
      return;
    }

    setState(() => _isExtractingLocation = true);

    try {
      var coords = _extractCoordinatesLocally(link);

      if (coords == null) {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'resolveGoogleMapsLink',
        );
        final result = await callable.call({'url': link});
        final data = Map<String, dynamic>.from(result.data as Map);

        if (data['success'] == true) {
          coords = {
            'lat': (data['latitude'] as num).toDouble(),
            'lng': (data['longitude'] as num).toDouble(),
          };
        } else {
          // ✅ New — the function now only ever returns success:true
          // for a coordinate it's confident is a real pin inside
          // Ghana. A failure here means it genuinely couldn't find
          // one — showing the function's own explanation is more
          // useful than a generic message.
          throw Exception(
            data['error'] as String? ?? 'No coordinates found in this link',
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _latCtrl.text = coords!['lat']!.toStringAsFixed(6);
        _lngCtrl.text = coords['lng']!.toStringAsFixed(6);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location extracted ✅'),
          backgroundColor: DColors.success,
        ),
      );
    } catch (e) {
      // 1. طباعة الخطأ الحقيقي في الكونسول عشان تقدر تشوفه بوضوح
      debugPrint('Maps Extraction Error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Extraction failed: $e'),
            backgroundColor: DColors.error,
            duration: const Duration(
              seconds: 5,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExtractingLocation = false);
    }
  }

  // ── Upload Image ───────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null || !mounted) return;

      setState(() => _isUploadingImage = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('providers')
          .child('${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');

      final metadata = SettableMetadata(
        contentType: pickedFile.mimeType ?? 'image/jpeg',
      );

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await storageRef.putData(bytes, metadata);
      } else {
        await storageRef.putFile(File(pickedFile.path), metadata);
      }

      final url = await storageRef.getDownloadURL();

      if (mounted) {
        setState(() {
          _imageCtrl.text = url;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload error: $e'),
            backgroundColor: DColors.error,
          ),
        );
      }
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingImage || _isExtractingLocation) return;
    final latitude = double.tryParse(_latCtrl.text.trim());
    final longitude = double.tryParse(_lngCtrl.text.trim());
    final noLocation =
        _latCtrl.text.trim().isEmpty && _lngCtrl.text.trim().isEmpty;
    if (!noLocation &&
        (latitude == null ||
            longitude == null ||
            !latitude.isFinite ||
            !longitude.isFinite ||
            latitude.abs() > 90 ||
            longitude.abs() > 180)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter both valid latitude and longitude, or clear both.',
          ),
        ),
      );
      return;
    }
    final discount = int.tryParse(_discountCtrl.text);
    final rating = double.tryParse(_ratingCtrl.text);
    if (discount == null ||
        discount < 0 ||
        discount > 100 ||
        rating == null ||
        !rating.isFinite ||
        rating < 0 ||
        rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discount must be 0–100 and rating must be 0–5.'),
        ),
      );
      return;
    }

    if (!_isEditing) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('providers')
            .get();
        if (!mounted) return;
        String normalized(String value) =>
            value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        final name = normalized(_nameCtrl.text);
        final address = normalized(_addressCtrl.text);
        final area = normalized(_district.isNotEmpty ? _district : _area);
        final matches = snapshot.docs.where((doc) {
          final data = doc.data();
          return normalized((data['name'] ?? '').toString()) == name &&
              normalized((data['address'] ?? '').toString()) == address &&
              normalized((data['area'] ?? '').toString()) == area;
        }).toList();
        if (matches.isNotEmpty) {
          final createAnyway = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Provider already exists'),
              content: const Text(
                'A provider with this name and address is already saved. '
                'Add its pharmacy, laboratory, or other services to that '
                'provider instead of creating another record.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Create anyway'),
                ),
              ],
            ),
          );
          if (createAnyway != true || !mounted) return;
        }
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not check existing providers: $error')),
        );
        return;
      }
    }

    final services = _servicesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final provider = (widget.provider ?? ProviderModel.empty()).copyWithFields(
      name: _nameCtrl.text.trim(),
      type: _selectedTypes.contains(_type) ? _type : _selectedTypes.first,
      types: _selectedTypes.toList(),
      address: _addressCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      area: _district.isNotEmpty ? _district : _area,
      discountPercent: int.tryParse(_discountCtrl.text) ?? 20,
      rating: double.tryParse(_ratingCtrl.text) ?? 4.0,
      isActive: _isActive,
      isInNetwork: _isInNetwork,
      speciality: _specialityCtrl.text.trim(),
      clearCoordinates: noLocation,
      latitude: latitude,
      longitude: longitude,
      services: services,
      workingHours: _hoursCtrl.text.trim(),
      website: _websiteCtrl.text.trim().isEmpty
          ? null
          : _websiteCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
    );

    if (_isEditing) {
      context.read<ProvidersBloc>().add(ProviderUpdateRequested(provider));
    } else {
      context.read<ProvidersBloc>().add(ProviderAddRequested(provider));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: 650,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // ── Title ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Provider' : 'Add Provider',
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

          // ── Form ─────────────────────────────
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // ── Name ──────────────────────
                  _L('Provider Name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Accra Medical Center',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ✅ ── Type (Dynamic) ──────────
                  _L('Provider categories'),
                  Text(
                    'Select all that apply. One provider can offer clinic, pharmacy, and laboratory services.',
                    style: DTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  if (!_typesLoaded)
                    const LinearProgressIndicator()
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dynamicTypes.map((item) {
                        final type = item['value']!;
                        final selected = _selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(item['label']!),
                          selected: selected,
                          onSelected: (value) {
                            if (!value && _selectedTypes.length == 1) return;
                            setState(() {
                              if (value) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                              if (!_needsSpecialty) _specialityCtrl.clear();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  // ✅ Doctor Specialty (conditional)
                  if (_needsSpecialty) ...[
                    const SizedBox(height: 12),
                    _L('Doctor Specialty *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _specialityCtrl.text.isNotEmpty &&
                              _specialties.contains(_specialityCtrl.text)
                          ? _specialityCtrl.text
                          : null,
                      hint: const Text('Select specialty'),
                      onChanged: (v) =>
                          setState(() => _specialityCtrl.text = v ?? ''),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.medical_services_outlined,
                          size: 18,
                        ),
                      ),
                      validator: (v) =>
                          _needsSpecialty && (v == null || v.isEmpty)
                          ? 'Specialty is required for doctors'
                          : null,
                      items: _specialties
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ✅ ── City (Dynamic) ──────────
                  _L('City'),
                  const SizedBox(height: 6),
                  if (!_citiesLoaded)
                    const LinearProgressIndicator()
                  else
                    DropdownButtonFormField<String>(
                      initialValue:
                          _area.isNotEmpty &&
                              _dynamicCities.any((c) => c['name'] == _area)
                          ? _area
                          : null,
                      hint: const Text('Select city'),
                      onChanged: (v) => setState(() {
                        _area = v ?? '';
                        _district = '';
                      }),
                      decoration: const InputDecoration(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'City is required' : null,
                      items: _dynamicCities
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['name'] as String,
                              child: Text(c['name'] as String),
                            ),
                          )
                          .toList(),
                    ),
                  // ✅ District / Area (conditional)
                  if (_area.isNotEmpty &&
                      _districtsForSelectedCity.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _L('District / Area (optional)'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _district.isNotEmpty &&
                              _districtsForSelectedCity.contains(_district)
                          ? _district
                          : null,
                      hint: const Text('Select district'),
                      onChanged: (v) => setState(() => _district = v ?? ''),
                      decoration: const InputDecoration(),
                      items: _districtsForSelectedCity
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Address ───────────────────
                  _L('Address'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 15 Street 233, Accra',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Address is required'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Phone ─────────────────────
                  _L('Phone Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+233 20 123 4567',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Phone is required'
                        : null,
                  ),

                  const SizedBox(height: 16),
                  // ── Discount + Rating ─────────
                  if (isMobile) ...[
                    _NumberField(
                      label: 'Discount %',
                      ctrl: _discountCtrl,
                      hint: '20',
                    ),
                    const SizedBox(height: 16),
                    _NumberField(
                      label: 'Rating (0-5)',
                      ctrl: _ratingCtrl,
                      hint: '4.5',
                      isDouble: true,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            label: 'Discount %',
                            ctrl: _discountCtrl,
                            hint: '20',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            label: 'Rating (0-5)',
                            ctrl: _ratingCtrl,
                            hint: '4.5',
                            isDouble: true,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // ── Working Hours ─────────────
                  _L('Working Hours'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _hoursCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Mon - Fri: 9:00 AM - 6:00 PM',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Services ──────────────────
                  _L('Services (comma-separated)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _servicesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'General Consultation, Lab Tests, X-Ray',
                    ),
                  ),

                  // ── Speciality (text — for non-doctor) ──
                  if (!_needsSpecialty) ...[
                    const SizedBox(height: 16),
                    _L('Speciality (optional)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _specialityCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. General Practice, Cardiology',
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ✅ ── Google Maps Link (auto-fill location) ──
                  _L('Paste Google Maps Link (optional)'),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mapsLinkCtrl,
                          decoration: const InputDecoration(
                            hintText:
                                'https://maps.app.goo.gl/... or full Maps link',
                            prefixIcon: Icon(Icons.map_outlined, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isExtractingLocation
                            ? null
                            : _extractLocationFromLink,
                        icon: _isExtractingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.pin_drop_outlined, size: 18),
                        label: Text(
                          _isExtractingLocation ? 'Reading...' : 'Extract',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paste any Google Maps link (short or full) — '
                    'the coordinates below fill in automatically.',
                    style: DTextStyles.bodySmall.copyWith(
                      color: DColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Location ──────────────────
                  _L('GPS Location (auto-filled — or edit manually)'),
                  const SizedBox(height: 6),
                  if (isMobile)
                    Column(
                      children: [
                        TextFormField(
                          controller: _latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Latitude  e.g. 5.6037',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Longitude  e.g. -0.1870',
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Latitude  e.g. 5.6037',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Longitude  e.g. -0.1870',
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // ── Website ───────────────────
                  _L('Website (optional)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _websiteCtrl,
                    decoration: const InputDecoration(
                      hintText: 'https://provider.com',
                    ),
                  ),

                  const SizedBox(height: 16),
                  // ── Image ─────────────────────
                  _L('Provider Image (optional)'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageCtrl,
                          decoration: const InputDecoration(
                            hintText: 'https://...',
                            prefixIcon: Icon(Icons.link_outlined, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isUploadingImage
                            ? null
                            : _pickAndUploadImage,
                        icon: _isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload_file, size: 18),
                        label: Text(
                          _isUploadingImage ? 'Uploading...' : 'Upload',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Image Preview
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _imageCtrl,
                    builder: (context, val, _) {
                      final url = val.text.trim();
                      if (url.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: DColors.border),
                              borderRadius: BorderRadius.circular(
                                DDimens.radiusMD,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                DDimens.radiusMD - 1,
                              ),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: DColors.textSecondary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  // ── Toggles ───────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ToggleTile(
                          label: 'Active',
                          subtitle: 'Visible in app',
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ToggleTile(
                          label: 'In Network',
                          subtitle: 'Full benefits apply',
                          value: _isInNetwork,
                          onChanged: (v) => setState(() => _isInNetwork = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Submit ────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isUploadingImage || _isExtractingLocation
                          ? null
                          : _submit,
                      child: Text(
                        _isEditing ? 'Update Provider' : 'Add Provider',
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
}

// ─────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────
class _L extends StatelessWidget {
  final String text;
  const _L(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: DTextStyles.label);
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool isDouble;

  const _NumberField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.isDouble = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          inputFormatters: isDouble
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(label, style: DTextStyles.label),
                Text(subtitle, style: DTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
