import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/usecases/discount_usecases.dart';
import '../../data/models/discount_model.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'discount_event.dart';
part 'discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final GetDiscountCodes _get;
  final CreateDiscountCode _create;
  final ToggleDiscountCode _toggle;
  final DeleteDiscountCode _delete;

  List<DiscountCodeEntity> _all = [];
  String _query = '';

  DiscountBloc({
    required GetDiscountCodes get,
    required CreateDiscountCode create,
    required ToggleDiscountCode toggle,
    required DeleteDiscountCode delete,
  }) : _get = get,
       _create = create,
       _toggle = toggle,
       _delete = delete,
       super(DiscountInitial()) {
    on<DiscountEvent>((event, emit) async {
      if (event is DiscountLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is DiscountSearchChanged) {
        _onSearch(event, emit);
        return;
      }
      if (event is DiscountCodeCreateRequested) {
        await _onCreate(event, emit);
        return;
      }
      if (event is DiscountCodeToggleRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is DiscountCodeDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  List<DiscountCodeEntity> _applyFilter() {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where(
          (c) =>
              c.code.toLowerCase().contains(q) ||
              c.organization.toLowerCase().contains(q) ||
              (c.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  Future<void> _onLoad(
    DiscountLoadRequested e,
    Emitter<DiscountState> emit,
  ) async {
    emit(DiscountLoading());
    final result = await _get();
    if (result.isLeft()) {
      emit(DiscountError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = result.getOrElse(() => []);
    emit(
      DiscountLoaded(all: _all, filtered: _applyFilter(), searchQuery: _query),
    );
  }

  void _onSearch(DiscountSearchChanged e, Emitter<DiscountState> emit) {
    _query = e.query;
    if (state is DiscountLoaded || state is DiscountActionSuccess) {
      emit(
        DiscountLoaded(
          all: _all,
          filtered: _applyFilter(),
          searchQuery: _query,
        ),
      );
    }
  }

  Future<void> _onCreate(
    DiscountCodeCreateRequested e,
    Emitter<DiscountState> emit,
  ) async {
    final result = await _create(e.code);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(DiscountError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }

    _all = [e.code, ..._all];
    emit(
      DiscountActionSuccess(
        message: 'Code "${e.code.code}" created!',
        all: _all,
        filtered: _applyFilter(),
        searchQuery: _query,
      ),
    );
  }

  Future<void> _onToggle(
    DiscountCodeToggleRequested e,
    Emitter<DiscountState> emit,
  ) async {
    final result = await _toggle(e.id, e.isActive);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(DiscountError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }

    _all = _all.map((c) {
      if (c.id == e.id) {
        return DiscountCodeModel(
          id: c.id,
          code: c.code,
          discountValue: c.discountValue,
          discountType: c.discountType,
          maxUses: c.maxUses,
          usedCount: c.usedCount,
          isActive: e.isActive,
          expiryDate: c.expiryDate,
          organization: c.organization,
          createdAt: c.createdAt,
          usedByUserIds: c.usedByUserIds,
          description: c.description,
        );
      }
      return c;
    }).toList();

    emit(
      DiscountActionSuccess(
        message: e.isActive ? 'Code activated' : 'Code deactivated',
        all: _all,
        filtered: _applyFilter(),
        searchQuery: _query,
      ),
    );
  }

  Future<void> _onDelete(
    DiscountCodeDeleteRequested e,
    Emitter<DiscountState> emit,
  ) async {
    final result = await _delete(e.id);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(DiscountError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }

    _all = _all.where((c) => c.id != e.id).toList();
    emit(
      DiscountActionSuccess(
        message: 'Code deleted',
        all: _all,
        filtered: _applyFilter(),
        searchQuery: _query,
      ),
    );
  }
}
