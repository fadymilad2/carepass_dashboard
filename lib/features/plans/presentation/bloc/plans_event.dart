part of 'plans_bloc.dart';

abstract class PlansEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlansLoadRequested extends PlansEvent {}

class PlanAddRequested extends PlansEvent {
  final PlanModel plan;
  PlanAddRequested(this.plan);
  @override
  List<Object?> get props => [plan.id];
}

class PlanUpdateRequested extends PlansEvent {
  final PlanModel plan;
  PlanUpdateRequested(this.plan);
  @override
  List<Object?> get props => [plan.id];
}

class PlanToggleRequested extends PlansEvent {
  final String id;
  final bool isActive;
  PlanToggleRequested({required this.id, required this.isActive});
  @override
  List<Object?> get props => [id, isActive];
}

class PlanDeleteRequested extends PlansEvent {
  final String id;
  PlanDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ─────────────────────────────────────────────
