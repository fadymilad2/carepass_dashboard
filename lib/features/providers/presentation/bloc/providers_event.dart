part of 'providers_bloc.dart';

abstract class ProvidersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProvidersLoadRequested extends ProvidersEvent {}

class ProvidersSearchChanged extends ProvidersEvent {
  final String query;
  ProvidersSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ProvidersTypeFilterChanged extends ProvidersEvent {
  final String type;
  ProvidersTypeFilterChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class ProvidersStatusFilterChanged extends ProvidersEvent {
  final String status;
  ProvidersStatusFilterChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class ProviderAddRequested extends ProvidersEvent {
  final ProviderModel provider;
  ProviderAddRequested(this.provider);
  @override
  List<Object?> get props => [provider.id];
}

class ProviderUpdateRequested extends ProvidersEvent {
  final ProviderModel provider;
  ProviderUpdateRequested(this.provider);
  @override
  List<Object?> get props => [provider.id];
}

class ProviderToggleStatusRequested extends ProvidersEvent {
  final String providerId;
  final bool isActive;
  ProviderToggleStatusRequested({
    required this.providerId,
    required this.isActive,
  });
  @override
  List<Object?> get props => [providerId, isActive];
}

class ProviderDeleteRequested extends ProvidersEvent {
  final String providerId;
  ProviderDeleteRequested(this.providerId);
  @override
  List<Object?> get props => [providerId];
}

// ── States ─────────────────────────────────────────────────────────────
