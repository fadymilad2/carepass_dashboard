part of 'discount_bloc.dart';

abstract class DiscountState extends Equatable {
  const DiscountState();
  @override
  List<Object?> get props => [];
}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class DiscountLoaded extends DiscountState {
  final List<DiscountCodeEntity> all;
  final List<DiscountCodeEntity> filtered;
  final String searchQuery;

  const DiscountLoaded({
    required this.all,
    required this.filtered,
    required this.searchQuery,
  });

  // Computed stats
  int get activeCount => all.where((c) => c.isActive && !c.isExpired).length;
  int get totalUses => all.fold(0, (s, c) => s + c.usedCount);
  int get bulkCount => all.where((c) => c.isBulk).length;

  @override
  List<Object?> get props => [all, filtered, searchQuery];
}

class DiscountActionSuccess extends DiscountState {
  final String message;
  final List<DiscountCodeEntity> all;
  final List<DiscountCodeEntity> filtered;
  final String searchQuery;

  const DiscountActionSuccess({
    required this.message,
    required this.all,
    required this.filtered,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [message, all];
}

class DiscountError extends DiscountState {
  final String message;
  final List<DiscountCodeEntity> all;

  const DiscountError({required this.message, required this.all});

  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────────
