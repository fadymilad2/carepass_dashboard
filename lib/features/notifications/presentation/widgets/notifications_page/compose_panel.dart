part of '../../pages/notifications_page.dart';

class _ComposePanel extends StatefulWidget {
  final bool sending;
  const _ComposePanel({required this.sending});

  @override
  State<_ComposePanel> createState() => _ComposePanelState();
}

class _ComposePanelState extends State<_ComposePanel> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';
  String _type = 'announcement';

  static const _targets = {
    'all': 'All Users',
    'active': 'Active Members',
    'expired': 'Expired Members',
  };

  static const _types = {
    'announcement': 'Announcement',
    'promo': 'Promotion',
    'system': 'System',
    'reminder': 'Reminder',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      return;
    }

    context.read<NotificationsBloc>().add(
      NotificationSendRequested(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        targetGroup: _target,
        targetUserIds: [],
        type: _type,
      ),
    );

    _titleCtrl.clear();
    _bodyCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Send Notification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto Expiry Reminder button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: DColors.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DDimens.radiusMD),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Expiry Reminders',
                        style: DTextStyles.label.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Runs daily at 9AM via Cloud Function',
                        style: DTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.sending
                      ? null
                      : () => context.read<NotificationsBloc>().add(
                          NotificationExpiryRemindersRequested(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Trigger Now'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Target audience
          Text('Target Audience', style: DTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _targets.entries.map((e) {
              final selected = _target == e.key;
              return ChoiceChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => setState(() => _target = e.key),
                selectedColor: DColors.primaryLight,
                labelStyle: DTextStyles.bodySmall.copyWith(
                  color: selected ? DColors.primary : DColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: selected ? DColors.primary : DColors.border,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Type
          Text('Notification Type', style: DTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _type,
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(),
            items: _types.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          // Title
          Text('Title', style: DTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. Special Offer for Members!',
            ),
          ),

          const SizedBox(height: 16),

          // Body
          Text('Message', style: DTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your message here...',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 20),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.sending ? null : () => _send(context),
              icon: widget.sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(widget.sending ? 'Sending...' : 'Send Notification'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  History Panel (unchanged — same bloc calls)
// ─────────────────────────────────────────────
