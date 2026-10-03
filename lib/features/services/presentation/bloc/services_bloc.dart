import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/usecases/services_usecases.dart';
import '../../data/models/service_model.dart';

// ── Events ─────────────────────────────────────────────
part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices _get;
  final AddService _add;
  final UpdateService _update;
  final ToggleService _toggle;
  final DeleteService _delete;

  List<ServiceEntity> _all = [];
  String _query = '';
  String _categoryFilter = 'all';

  ServicesBloc({
    required GetServices get,
    required AddService add,
    required UpdateService update,
    required ToggleService toggle,
    required DeleteService delete,
  }) : _get = get,
       _add = add,
       _update = update,
       _toggle = toggle,
       _delete = delete,
       super(ServicesInitial()) {
    on<ServicesEvent>((event, emit) async {
      if (event is ServicesLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is ServicesSearchChanged) {
        _onSearch(event, emit);
        return;
      }
      if (event is ServicesCategoryFilterChanged) {
        _onCategoryFilter(event, emit);
        return;
      }
      if (event is ServiceAddRequested) {
        await _onAdd(event, emit);
        return;
      }
      if (event is ServiceUpdateRequested) {
        await _onUpdate(event, emit);
        return;
      }
      if (event is ServiceToggleRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is ServiceDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  List<ServiceEntity> _applyFilters() {
    return _all.where((s) {
      final matchSearch =
          _query.isEmpty ||
          s.name.toLowerCase().contains(_query) ||
          s.providerName.toLowerCase().contains(_query) ||
          s.categoryLabel.toLowerCase().contains(_query);

      final matchCat =
          _categoryFilter == 'all' || s.category == _categoryFilter;

      return matchSearch && matchCat;
    }).toList();
  }

  ServicesLoaded _loaded() => ServicesLoaded(
    all: _all,
    filtered: _applyFilters(),
    searchQuery: _query,
    categoryFilter: _categoryFilter,
  );

  Future<void> _onLoad(
    ServicesLoadRequested e,
    Emitter<ServicesState> emit,
  ) async {
    emit(ServicesLoading());
    final result = await _get(providerId: e.providerId);
    if (result.isLeft()) {
      emit(ServicesError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = result.getOrElse(() => []);
    emit(_loaded());
  }

  void _onSearch(ServicesSearchChanged e, Emitter<ServicesState> emit) {
    _query = e.query.toLowerCase();
    if (state is ServicesLoaded || state is ServicesActionSuccess) {
      emit(_loaded());
    }
  }

  void _onCategoryFilter(
    ServicesCategoryFilterChanged e,
    Emitter<ServicesState> emit,
  ) {
    _categoryFilter = e.category;
    if (state is ServicesLoaded || state is ServicesActionSuccess) {
      emit(_loaded());
    }
  }

  Future<void> _onAdd(
    ServiceAddRequested e,
    Emitter<ServicesState> emit,
  ) async {
    final result = await _add(e.service);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(ServicesError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = [e.service, ..._all];
    emit(
      ServicesActionSuccess(
        message: 'Service added successfully',
        all: _all,
        filtered: _applyFilters(),
        searchQuery: _query,
        categoryFilter: _categoryFilter,
      ),
    );
  }

  Future<void> _onUpdate(
    ServiceUpdateRequested e,
    Emitter<ServicesState> emit,
  ) async {
    final result = await _update(e.service);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(ServicesError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = _all.map((s) => s.id == e.service.id ? e.service : s).toList();
    emit(
      ServicesActionSuccess(
        message: 'Service updated',
        all: _all,
        filtered: _applyFilters(),
        searchQuery: _query,
        categoryFilter: _categoryFilter,
      ),
    );
  }

  Future<void> _onToggle(
    ServiceToggleRequested e,
    Emitter<ServicesState> emit,
  ) async {
    final result = await _toggle(e.id, e.isAvailable);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(ServicesError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = _all.map((s) {
      if (s.id == e.id) {
        return ServiceModel(
          id: s.id,
          name: s.name,
          category: s.category,
          providerId: s.providerId,
          providerName: s.providerName,
          discountPercent: s.discountPercent,
          isAvailable: e.isAvailable,
          createdAt: s.createdAt,
          description: s.description,
        );
      }
      return s;
    }).toList();
    emit(
      ServicesActionSuccess(
        message: e.isAvailable ? 'Service enabled' : 'Service disabled',
        all: _all,
        filtered: _applyFilters(),
        searchQuery: _query,
        categoryFilter: _categoryFilter,
      ),
    );
  }

  Future<void> _onDelete(
    ServiceDeleteRequested e,
    Emitter<ServicesState> emit,
  ) async {
    final result = await _delete(e.id);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(ServicesError(message: result.fold((f) => f, (_) => ''), all: _all));
      return;
    }
    _all = _all.where((s) => s.id != e.id).toList();
    emit(
      ServicesActionSuccess(
        message: 'Service deleted',
        all: _all,
        filtered: _applyFilters(),
        searchQuery: _query,
        categoryFilter: _categoryFilter,
      ),
    );
  }
}
