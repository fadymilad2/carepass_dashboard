import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/plans_usecases.dart';
import '../../data/models/plan_model.dart';

part 'plans_event.dart';
part 'plans_state.dart';

class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final GetPlansAdmin _get;
  final AddPlan _add;
  final UpdatePlan _update;
  final TogglePlan _toggle;
  final DeletePlan _delete;

  List<PlanEntity> _plans = [];

  PlansBloc({
    required GetPlansAdmin get,
    required AddPlan add,
    required UpdatePlan update,
    required TogglePlan toggle,
    required DeletePlan delete,
  }) : _get = get,
       _add = add,
       _update = update,
       _toggle = toggle,
       _delete = delete,
       super(PlansInitial()) {
    on<PlansEvent>((event, emit) async {
      if (event is PlansLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is PlanAddRequested) {
        await _onAdd(event, emit);
        return;
      }
      if (event is PlanUpdateRequested) {
        await _onUpdate(event, emit);
        return;
      }
      if (event is PlanToggleRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is PlanDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  Future<void> _onLoad(PlansLoadRequested e, Emitter<PlansState> emit) async {
    emit(PlansLoading());
    final result = await _get();
    if (result.isLeft()) {
      emit(
        PlansError(message: result.fold((f) => f, (_) => ''), plans: _plans),
      );
      return;
    }
    _plans = result.getOrElse(() => []);
    emit(PlansLoaded(_plans));
  }

  Future<void> _onAdd(PlanAddRequested e, Emitter<PlansState> emit) async {
    final result = await _add(e.plan);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        PlansError(message: result.fold((f) => f, (_) => ''), plans: _plans),
      );
      return;
    }
    final fresh = await _get();
    if (emit.isDone) return;
    if (fresh.isLeft()) {
      emit(
        PlansError(
          message: 'Plan saved, but refresh failed. Please reload.',
          plans: _plans,
        ),
      );
      return;
    }
    _plans = fresh.getOrElse(() => []);
    emit(PlansActionSuccess(message: 'Plan added', plans: _plans));
  }

  Future<void> _onUpdate(
    PlanUpdateRequested e,
    Emitter<PlansState> emit,
  ) async {
    final result = await _update(e.plan);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        PlansError(message: result.fold((f) => f, (_) => ''), plans: _plans),
      );
      return;
    }
    _plans = _plans.map((p) => p.id == e.plan.id ? e.plan : p).toList();
    emit(PlansActionSuccess(message: 'Plan updated', plans: _plans));
  }

  Future<void> _onToggle(
    PlanToggleRequested e,
    Emitter<PlansState> emit,
  ) async {
    final result = await _toggle(e.id, e.isActive);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        PlansError(message: result.fold((f) => f, (_) => ''), plans: _plans),
      );
      return;
    }
    _plans = _plans.map((p) {
      if (p.id == e.id) {
        return PlanModel(
          id: p.id,
          name: p.name,
          price: p.price,
          currency: p.currency,
          durationDays: p.durationDays,
          type: p.type,
          features: p.features,
          isActive: e.isActive,
          isPopular: p.isPopular,
          order: p.order,
        );
      }
      return p;
    }).toList();
    emit(
      PlansActionSuccess(
        message: e.isActive ? 'Plan activated' : 'Plan deactivated',
        plans: _plans,
      ),
    );
  }

  Future<void> _onDelete(
    PlanDeleteRequested e,
    Emitter<PlansState> emit,
  ) async {
    final result = await _delete(e.id);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        PlansError(message: result.fold((f) => f, (_) => ''), plans: _plans),
      );
      return;
    }
    _plans = _plans.where((p) => p.id != e.id).toList();
    emit(PlansActionSuccess(message: 'Plan deleted', plans: _plans));
  }
}
