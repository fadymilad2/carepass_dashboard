import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/usecases/banners_usecases.dart';
import '../../data/models/banner_model.dart';

part 'banners_event.dart';
part 'banners_state.dart';

class BannersBloc extends Bloc<BannersEvent, BannersState> {
  final GetBanners _get;
  final AddBanner _add;
  final UpdateBanner _update;
  final ToggleBannerStatus _toggle;
  final DeleteBanner _delete;

  final ReorderBanners _reorder;

  List<BannerEntity> _banners = [];

  BannersBloc({
    required GetBanners get,
    required ReorderBanners reorder,
    required AddBanner add,
    required UpdateBanner update,
    required ToggleBannerStatus toggle,
    required DeleteBanner delete,
  }) : _get = get,
       _reorder = reorder,
       _add = add,
       _update = update,
       _toggle = toggle,
       _delete = delete,
       super(BannersInitial()) {
    on<BannersEvent>((event, emit) async {
      if (event is BannersLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is BannerAddRequested) {
        await _onAdd(event, emit);
        return;
      }
      if (event is BannerUpdateRequested) {
        await _onUpdate(event, emit);
        return;
      }
      if (event is BannerToggleRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is BannerDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
      if (event is BannersReordered) {
        await _onReorder(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  Future<void> _onLoad(
    BannersLoadRequested e,
    Emitter<BannersState> emit,
  ) async {
    emit(BannersLoading());
    final result = await _get();
    if (result.isLeft()) {
      emit(BannersError(result.fold((f) => f, (_) => '')));
      return;
    }
    _banners = result.getOrElse(() => []);
    emit(BannersLoaded(_banners));
  }

  Future<void> _onAdd(BannerAddRequested e, Emitter<BannersState> emit) async {
    final result = await _add(e.banner);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(BannersError(result.fold((f) => f, (_) => '')));
      return;
    }
    final fresh = await _get();
    if (emit.isDone) return;
    if (fresh.isLeft()) {
      emit(BannersError('Banner saved, but refresh failed. Please reload.'));
      return;
    }
    _banners = fresh.getOrElse(() => []);
    emit(BannersActionSuccess(message: 'Banner added', banners: _banners));
  }

  Future<void> _onUpdate(
    BannerUpdateRequested e,
    Emitter<BannersState> emit,
  ) async {
    final result = await _update(e.banner);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(BannersError(result.fold((f) => f, (_) => '')));
      return;
    }
    _banners = _banners.map((b) => b.id == e.banner.id ? e.banner : b).toList();
    emit(BannersActionSuccess(message: 'Banner updated', banners: _banners));
  }

  Future<void> _onToggle(
    BannerToggleRequested e,
    Emitter<BannersState> emit,
  ) async {
    final result = await _toggle(e.id, e.isActive);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(BannersError(result.fold((f) => f, (_) => '')));
      return;
    }
    _banners = _banners.map((b) {
      if (b.id == e.id) {
        return BannerModel(
          id: b.id,
          title: b.title,
          subtitle: b.subtitle,
          imageUrl: b.imageUrl,
          type: b.type,
          providerId: b.providerId,
          providerName: b.providerName,
          discountPercent: b.discountPercent,
          areas: b.areas,
          isActive: e.isActive,
          order: b.order,
          actionUrl: b.actionUrl,
          createdAt: b.createdAt,
        );
      }
      return b;
    }).toList();
    emit(
      BannersActionSuccess(
        message: e.isActive ? 'Banner activated' : 'Banner hidden',
        banners: _banners,
      ),
    );
  }

  Future<void> _onDelete(
    BannerDeleteRequested e,
    Emitter<BannersState> emit,
  ) async {
    final result = await _delete(e.id);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(BannersError(result.fold((f) => f, (_) => '')));
      return;
    }
    _banners = _banners.where((b) => b.id != e.id).toList();
    emit(BannersActionSuccess(message: 'Banner deleted', banners: _banners));
  }

  Future<void> _onReorder(
    BannersReordered e,
    Emitter<BannersState> emit,
  ) async {
    final ids = e.orderedIds;
    final currentIds = _banners.map((b) => b.id).toSet();
    if (ids.length != currentIds.length ||
        ids.toSet().length != ids.length ||
        !currentIds.containsAll(ids)) {
      emit(const BannersError('Refresh banners before reordering.'));
      return;
    }
    final result = await _reorder(ids);
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(BannersError(result.fold((e) => e, (_) => '')));
      return;
    }
    final fresh = await _get();
    if (emit.isDone) return;
    fresh.fold((error) => emit(BannersError(error)), (banners) {
      _banners = banners;
      emit(BannersLoaded(_banners));
    });
  }
}
