import 'package:carepass_dashboard/features/providers/data/models/provider_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('multiple categories survive save, reload and unrelated edits', () {
    final provider = ProviderModel.empty().copyWithFields(
      name: 'Medical Complex',
      type: 'clinic',
      types: ['clinic', 'pharmacy', 'lab'],
    );
    final reloaded = ProviderModel.fromFirestore(
      provider.toFirestore(),
      provider.id,
    ).copyWithFields(isActive: false, phoneNumber: '12345');
    expect(reloaded.id, provider.id);
    expect(reloaded.providerTypes, ['clinic', 'pharmacy', 'lab']);
    expect(reloaded.offersType('pharmacy'), isTrue);
    expect(reloaded.offersType('lab'), isTrue);
    expect(reloaded.offersType('dental'), isFalse);
    expect(reloaded.typeLabel, 'Clinic · Pharmacy · Laboratory');
  });

  test('legacy providers save a compatible category list', () {
    final provider = ProviderModel.fromFirestore({'type': 'pharmacy'}, 'old');
    expect(provider.providerTypes, ['pharmacy']);
    expect(provider.toFirestore()['types'], ['pharmacy']);
  });

  test('removing a category does not restore it from legacy type', () {
    final provider = ProviderModel.fromFirestore({
      'type': 'clinic',
      'types': ['pharmacy', 'lab'],
    }, 'complex');
    expect(provider.offersType('clinic'), isFalse);
  });
}
