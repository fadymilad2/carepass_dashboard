part of 'plans_bloc.dart';

abstract class PlansState extends Equatable {
  const PlansState();
  @override
  List<Object?> get props => [];
}

class PlansInitial extends PlansState {}

class PlansLoading extends PlansState {}

class PlansLoaded extends PlansState {
  final List<PlanEntity> plans;
  const PlansLoaded(this.plans);
  @override
  List<Object?> get props => [plans];
}

class PlansActionSuccess extends PlansState {
  final String message;
  final List<PlanEntity> plans;
  const PlansActionSuccess({required this.message, required this.plans});
  @override
  List<Object?> get props => [message, plans];
}

class PlansError extends PlansState {
  final String message;
  final List<PlanEntity> plans;
  const PlansError({required this.message, required this.plans});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────
