part of 'providers_bloc.dart';

abstract class ProvidersState extends Equatable {
  const ProvidersState();
  @override
  List<Object?> get props => [];
}

class ProvidersInitial extends ProvidersState {}

class ProvidersLoading extends ProvidersState {}

class ProvidersLoaded extends ProvidersState {
  final List<ProviderEntity> all;
  final List<ProviderEntity> filtered;
  final String typeFilter;
  final String statusFilter;
  final String searchQuery;

  const ProvidersLoaded({
    required this.all,
    required this.filtered,
    required this.typeFilter,
    required this.statusFilter,
    required this.searchQuery,
  });

  int get activeCount => all.where((p) => p.isActive).length;

  int get inactiveCount => all.where((p) => !p.isActive).length;

  @override
  List<Object?> get props => [
    all,
    filtered,
    typeFilter,
    statusFilter,
    searchQuery,
  ];
}

class ProvidersActionSuccess extends ProvidersState {
  final String message;
  final List<ProviderEntity> all;
  final List<ProviderEntity> filtered;
  final String typeFilter;
  final String statusFilter;
  final String searchQuery;

  const ProvidersActionSuccess({
    required this.message,
    required this.all,
    required this.filtered,
    required this.typeFilter,
    required this.statusFilter,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [message, all];
}

class ProvidersError extends ProvidersState {
  final String message;
  const ProvidersError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────────
