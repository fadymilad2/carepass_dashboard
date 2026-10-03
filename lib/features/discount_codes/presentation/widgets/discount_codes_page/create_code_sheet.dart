part of '../../pages/discount_codes_page.dart';

class _CreateCodeSheet extends StatefulWidget {
  const _CreateCodeSheet();

  @override
  State<_CreateCodeSheet> createState() => _CreateCodeSheetState();
}

class _CreateCodeSheetState extends State<_CreateCodeSheet> {
  final _codeCtrl = TextEditingController();
  final _discCtrl = TextEditingController(text: '20');
  final _maxCtrl = TextEditingController(text: '0');
  final _orgCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'percent';
  DateTime? _expiry;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _discCtrl.dispose();
    _maxCtrl.dispose();
    _orgCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _generateCode() {
    final id = const Uuid().v4();
    return 'CP${id.substring(0, 6).toUpperCase()}';
  }

  void _submit(BuildContext context) {
    if (_codeCtrl.text.trim().isEmpty || _discCtrl.text.trim().isEmpty) {
      return;
    }

    final discount = double.tryParse(_discCtrl.text.trim());
    final maxUses = int.tryParse(_maxCtrl.text.trim());
    if (discount == null ||
        !discount.isFinite ||
        discount <= 0 ||
        (_type == 'percent' && discount > 100) ||
        maxUses == null ||
        maxUses < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid discount and a non-negative usage limit.',
          ),
        ),
      );
      return;
    }
    final code = DiscountCodeModel.empty().copyWithFields(
      code: _codeCtrl.text.trim().toUpperCase(),
      discountValue: discount,
      discountType: _type,
      maxUses: maxUses,
      organization: _orgCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      expiryDate: _expiry?.toIso8601String() ?? '',
      isActive: true,
    );

    // ✅ التعديل هنا: قفل الدايالوج بطريقة آمنة مع go_router
    context.read<DiscountBloc>().add(DiscountCodeCreateRequested(code));
    Navigator.of(context, rootNavigator: true).pop();
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
        mainAxisSize: MainAxisSize.min, // عشان ميبقاش طويل عالفاضي
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
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Create Discount Code', style: DTextStyles.h3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                // Code
                Text('Code', style: DTextStyles.label),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Z0-9]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. SAVE20',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _codeCtrl.text = _generateCode()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Generate'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Type + Value
                if (isMobile) ...[
                  Text('Type', style: DTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(),
                    onChanged: (v) => setState(() => _type = v!),
                    items: const [
                      DropdownMenuItem(
                        value: 'percent',
                        child: Text('Percentage %'),
                      ),
                      DropdownMenuItem(
                        value: 'fixed',
                        child: Text('Fixed GHS'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Value', style: DTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _discCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '20',
                      suffixText: _type == 'percent' ? '%' : 'GHS',
                    ),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type', style: DTextStyles.label),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _type,
                              decoration: const InputDecoration(),
                              onChanged: (v) => setState(() => _type = v!),
                              items: const [
                                DropdownMenuItem(
                                  value: 'percent',
                                  child: Text('Percentage %'),
                                ),
                                DropdownMenuItem(
                                  value: 'fixed',
                                  child: Text('Fixed GHS'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Value', style: DTextStyles.label),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _discCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '20',
                                suffixText: _type == 'percent' ? '%' : 'GHS',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                Text('Max Uses (0 = unlimited)', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: '0'),
                ),

                const SizedBox(height: 16),

                Text('Organization (optional)', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _orgCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Accra Teaching Hospital',
                    prefixIcon: Icon(Icons.business_outlined, size: 18),
                  ),
                ),

                const SizedBox(height: 16),

                Text('Description (optional)', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Internal note about this code',
                  ),
                ),

                const SizedBox(height: 16),

                Text('Expiry Date (optional)', style: DTextStyles.label),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: DColors.primary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _expiry = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: DColors.background,
                      borderRadius: BorderRadius.circular(DDimens.radiusMD),
                      border: Border.all(color: DColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: DColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _expiry != null
                                ? DateFormat('MMM d, y').format(_expiry!)
                                : 'No expiry date',
                            style: DTextStyles.body.copyWith(
                              color: _expiry != null
                                  ? DColors.textPrimary
                                  : DColors.textHint,
                            ),
                          ),
                        ),
                        if (_expiry != null)
                          GestureDetector(
                            onTap: () => setState(() => _expiry = null),
                            child: const Icon(
                              Icons.clear,
                              size: 16,
                              color: DColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _submit(context),
                    child: const Text('Create Code'),
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
