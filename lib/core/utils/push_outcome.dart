class PushOutcome {
  final int? acceptedCount;
  final String status;
  const PushOutcome(this.acceptedCount, this.status);
  bool get completed => status == 'accepted';
  static PushOutcome fromResponse(
    dynamic response, {
    required bool broadcast,
    required int requested,
  }) {
    if (response is! Map ||
        response['error'] != null ||
        response['sent'] is! int) {
      return const PushOutcome(0, 'failed');
    }
    final int sent = response['sent'];
    if (broadcast) {
      return sent == -1
          ? const PushOutcome(null, 'accepted')
          : const PushOutcome(0, 'failed');
    }
    if (sent < 0 || sent > requested) return const PushOutcome(0, 'failed');
    return PushOutcome(
      sent,
      sent == requested && requested > 0
          ? 'accepted'
          : sent > 0
          ? 'partial'
          : 'failed',
    );
  }
}
