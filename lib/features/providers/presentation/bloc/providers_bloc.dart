import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/provider_entity.dart';
import '../../domain/usecases/providers_usecases.dart';
import '../../data/models/provider_model.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'providers_event.dart';
part 'providers_state.dart';

class ProvidersBloc extends Bloc<ProvidersEvent, ProvidersState> {
  final GetProviders _get;
  final AddProvider _add;
  final UpdateProvider _update;
  final ToggleProviderStatus _toggle;
  final DeleteProvider _delete;

  List<ProviderEntity> _all = [];
  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _searchQuery = '';

  ProvidersBloc({
    required GetProviders get,
    required AddProvider add,
    required UpdateProvider update,
    required ToggleProviderStatus toggle,
    required DeleteProvider delete,
  }) : _get = get,
       _add = add,
       _update = update,
       _toggle = toggle,
       _delete = delete,
       super(ProvidersInitial()) {
    on<ProvidersEvent>((event, emit) async {
      if (event is ProvidersLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is ProvidersSearchChanged) {
        _onSearch(event, emit);
        return;
      }
      if (event is ProvidersTypeFilterChanged) {
        _onTypeFilter(event, emit);
        return;
      }
      if (event is ProvidersStatusFilterChanged) {
        _onStatusFilter(event, emit);
        return;
      }
      if (event is ProviderAddRequested) {
        await _onAdd(event, emit);
        return;
      }
      if (event is ProviderUpdateRequested) {
        await _onUpdate(event, emit);
        return;
      }
      if (event is ProviderToggleStatusRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is ProviderDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  List<ProviderEntity> _applyFilters() {
    return _all.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.area.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);

      final matchType = _typeFilter == 'all' || p.offersType(_typeFilter);

      final matchStatus =
          _statusFilter == 'all' ||
          (_statusFilter == 'active' && p.isActive) ||
          (_statusFilter == 'inactive' && !p.isActive);

      return matchSearch && matchType && matchStatus;
    }).toList();
  }

  ProvidersLoaded _buildLoadedState(String message) => ProvidersLoaded(
    all: _all,
    filtered: _applyFilters(),
    typeFilter: _typeFilter,
    statusFilter: _statusFilter,
    searchQuery: _searchQuery,
  );

  Future<void> _onLoad(
    ProvidersLoadRequested e,
    Emitter<ProvidersState> emit,
  ) async {
    emit(ProvidersLoading());
    final result = await _get();

    if (result.isLeft()) {
      emit(ProvidersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _all = result.getOrElse(() => []);
    emit(_buildLoadedState(''));
  }

  void _onSearch(ProvidersSearchChanged e, Emitter<ProvidersState> emit) {
    _searchQuery = e.query;
    if (state is ProvidersLoaded || state is ProvidersActionSuccess) {
      emit(_buildLoadedState(''));
    }
  }

  void _onTypeFilter(
    ProvidersTypeFilterChanged e,
    Emitter<ProvidersState> emit,
  ) {
    _typeFilter = e.type;
    if (state is ProvidersLoaded || state is ProvidersActionSuccess) {
      emit(_buildLoadedState(''));
    }
  }

  void _onStatusFilter(
    ProvidersStatusFilterChanged e,
    Emitter<ProvidersState> emit,
  ) {
    _statusFilter = e.status;
    if (state is ProvidersLoaded || state is ProvidersActionSuccess) {
      emit(_buildLoadedState(''));
    }
  }

  Future<void> _onAdd(
    ProviderAddRequested e,
    Emitter<ProvidersState> emit,
  ) async {
    final result = await _add(e.provider);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(ProvidersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _all = [e.provider, ..._all];
    emit(
      ProvidersActionSuccess(
        message: 'Provider added successfully',
        all: _all,
        filtered: _applyFilters(),
        typeFilter: _typeFilter,
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<void> _onUpdate(
    ProviderUpdateRequested e,
    Emitter<ProvidersState> emit,
  ) async {
    final result = await _update(e.provider);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(ProvidersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _all = _all.map((p) => p.id == e.provider.id ? e.provider : p).toList();

    emit(
      ProvidersActionSuccess(
        message: 'Provider updated successfully',
        all: _all,
        filtered: _applyFilters(),
        typeFilter: _typeFilter,
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<void> _onToggle(
    ProviderToggleStatusRequested e,
    Emitter<ProvidersState> emit,
  ) async {
    final result = await _toggle(e.providerId, e.isActive);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(ProvidersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _all = _all.map((p) {
      if (p.id == e.providerId) {
        return ProviderModel(
          id: p.id,
          name: p.name,
          type: p.type,
          types: p.types,
          address: p.address,
          phoneNumber: p.phoneNumber,
          area: p.area,
          latitude: p.latitude,
          longitude: p.longitude,
          discountPercent: p.discountPercent,
          rating: p.rating,
          isActive: e.isActive,
          isInNetwork: p.isInNetwork,
          imageUrl: p.imageUrl,
          services: p.services,
          workingHours: p.workingHours,
          website: p.website,
          createdAt: p.createdAt,
          speciality: p.speciality,
        );
      }
      return p;
    }).toList();

    emit(
      ProvidersActionSuccess(
        message: e.isActive ? 'Provider activated' : 'Provider deactivated',
        all: _all,
        filtered: _applyFilters(),
        typeFilter: _typeFilter,
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
      ),
    );
  }

  Future<void> _onDelete(
    ProviderDeleteRequested e,
    Emitter<ProvidersState> emit,
  ) async {
    final result = await _delete(e.providerId);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(ProvidersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _all = _all.where((p) => p.id != e.providerId).toList();

    emit(
      ProvidersActionSuccess(
        message: 'Provider deleted',
        all: _all,
        filtered: _applyFilters(),
        typeFilter: _typeFilter,
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
      ),
    );
  }
}
