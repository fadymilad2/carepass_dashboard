part of '../../pages/plans_page.dart';

class _PlanFormSheet extends StatefulWidget {
  final PlanModel? plan;
  const _PlanFormSheet({this.plan});
  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _featureCtrl = TextEditingController();

  String _currency = 'GHS';
  String _type = 'individual';
  bool _isActive = true;
  bool _isPopular = false;
  List<String> _features = [];

  bool get _isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameCtrl.text = p?.name ?? '';
    _priceCtrl.text = p?.price.toString() ?? '';
    _daysCtrl.text = '${p?.durationDays ?? 30}';
    _currency = p?.currency ?? 'GHS';
    _type = p?.type ?? 'individual';
    _isActive = p?.isActive ?? true;
    _isPopular = p?.isPopular ?? false;
    _features = List<String>.from(p?.features ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _daysCtrl.dispose();
    _featureCtrl.dispose();
    super.dispose();
  }

  void _addFeature() {
    if (_featureCtrl.text.trim().isEmpty) return;
    setState(() {
      _features.add(_featureCtrl.text.trim());
      _featureCtrl.clear();
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    final days = int.tryParse(_daysCtrl.text.trim());
    if (price == null ||
        !price.isFinite ||
        price < 0 ||
        days == null ||
        days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid non-negative price and a positive duration.',
          ),
        ),
      );
      return;
    }
    final plan = (widget.plan ?? PlanModel.empty()).copyWithFields(
      name: _nameCtrl.text.trim(),
      price: price,
      currency: _currency,
      durationDays: days,
      type: _type,
      features: _features,
      isActive: _isActive,
      isPopular: _isPopular,
    );

    if (_isEditing) {
      context.read<PlansBloc>().add(PlanUpdateRequested(plan));
    } else {
      context.read<PlansBloc>().add(PlanAddRequested(plan));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    _isEditing ? 'Edit Plan' : 'Add Plan',
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
                // Name
                Text('Plan Name', style: DTextStyles.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Standard, Premium',
                  ),
                ),

                const SizedBox(height: 16),

                // Price + Currency
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: DTextStyles.label),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '49.99',
                              prefixText: '$_currency ',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Currency', style: DTextStyles.label),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            decoration: const InputDecoration(),
                            onChanged: (v) => setState(() => _currency = v!),
                            items: const [
                              DropdownMenuItem(
                                value: 'GHS',
                                child: Text('GHS'),
                              ),
                              DropdownMenuItem(
                                value: 'USD',
                                child: Text('USD'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Duration + Type
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration (Days)', style: DTextStyles.label),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _daysCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(hintText: '30'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                value: 'individual',
                                child: Text('Individual'),
                              ),
                              DropdownMenuItem(
                                value: 'family',
                                child: Text('Family'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Features
                Text('Features', style: DTextStyles.label),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _featureCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add a feature...',
                        ),
                        onFieldSubmitted: (_) => _addFeature(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addFeature,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),

                if (_features.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._features.asMap().entries.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: DColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: DColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e.value, style: DTextStyles.body),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 14,
                              color: DColors.error,
                            ),
                            onPressed: () =>
                                setState(() => _features.removeAt(e.key)),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Toggles
                Row(
                  children: [
                    Expanded(
                      child: _Toggle(
                        label: 'Active',
                        subtitle: 'Visible in app',
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Toggle(
                        label: 'Popular',
                        subtitle: 'Highlighted',
                        value: _isPopular,
                        onChanged: (v) => setState(() => _isPopular = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isEditing ? 'Update Plan' : 'Add Plan'),
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
