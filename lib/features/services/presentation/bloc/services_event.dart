part of 'services_bloc.dart';

abstract class ServicesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServicesLoadRequested extends ServicesEvent {
  final String? providerId;
  ServicesLoadRequested({this.providerId});
  @override
  List<Object?> get props => [providerId];
}

class ServicesSearchChanged extends ServicesEvent {
  final String query;
  ServicesSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ServicesCategoryFilterChanged extends ServicesEvent {
  final String category;
  ServicesCategoryFilterChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ServiceAddRequested extends ServicesEvent {
  final ServiceModel service;
  ServiceAddRequested(this.service);
  @override
  List<Object?> get props => [service.id];
}

class ServiceUpdateRequested extends ServicesEvent {
  final ServiceModel service;
  ServiceUpdateRequested(this.service);
  @override
  List<Object?> get props => [service.id];
}

class ServiceToggleRequested extends ServicesEvent {
  final String id;
  final bool isAvailable;
  ServiceToggleRequested({required this.id, required this.isAvailable});
  @override
  List<Object?> get props => [id, isAvailable];
}

class ServiceDeleteRequested extends ServicesEvent {
  final String id;
  ServiceDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ─────────────────────────────────────────────
