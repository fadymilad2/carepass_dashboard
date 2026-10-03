part of 'services_bloc.dart';

abstract class ServicesState extends Equatable {
  const ServicesState();
  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceEntity> all;
  final List<ServiceEntity> filtered;
  final String searchQuery;
  final String categoryFilter;

  const ServicesLoaded({
    required this.all,
    required this.filtered,
    required this.searchQuery,
    required this.categoryFilter,
  });

  int get availableCount => all.where((s) => s.isAvailable).length;

  @override
  List<Object?> get props => [all, filtered, searchQuery, categoryFilter];
}

class ServicesActionSuccess extends ServicesState {
  final String message;
  final List<ServiceEntity> all;
  final List<ServiceEntity> filtered;
  final String searchQuery;
  final String categoryFilter;

  const ServicesActionSuccess({
    required this.message,
    required this.all,
    required this.filtered,
    required this.searchQuery,
    required this.categoryFilter,
  });

  @override
  List<Object?> get props => [message, all];
}

class ServicesError extends ServicesState {
  final String message;
  final List<ServiceEntity> all;
  const ServicesError({required this.message, required this.all});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────
