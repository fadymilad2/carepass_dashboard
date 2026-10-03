part of 'discount_bloc.dart';

abstract class DiscountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiscountLoadRequested extends DiscountEvent {}

class DiscountSearchChanged extends DiscountEvent {
  final String query;
  DiscountSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class DiscountCodeCreateRequested extends DiscountEvent {
  final DiscountCodeModel code;
  DiscountCodeCreateRequested(this.code);
  @override
  List<Object?> get props => [code.code];
}

class DiscountCodeToggleRequested extends DiscountEvent {
  final String id;
  final bool isActive;
  DiscountCodeToggleRequested({required this.id, required this.isActive});
  @override
  List<Object?> get props => [id, isActive];
}

class DiscountCodeDeleteRequested extends DiscountEvent {
  final String id;
  DiscountCodeDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ─────────────────────────────────────────────────────────────
