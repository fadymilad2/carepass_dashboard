part of 'banners_bloc.dart';

abstract class BannersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BannersLoadRequested extends BannersEvent {}

class BannerAddRequested extends BannersEvent {
  final BannerModel banner;
  BannerAddRequested(this.banner);
  @override
  List<Object?> get props => [banner.id];
}

class BannerUpdateRequested extends BannersEvent {
  final BannerModel banner;
  BannerUpdateRequested(this.banner);
  @override
  List<Object?> get props => [banner.id];
}

class BannerToggleRequested extends BannersEvent {
  final String id;
  final bool isActive;
  BannerToggleRequested({required this.id, required this.isActive});
  @override
  List<Object?> get props => [id, isActive];
}

class BannerDeleteRequested extends BannersEvent {
  final String id;
  BannerDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class BannersReordered extends BannersEvent {
  final List<String> orderedIds;
  BannersReordered(this.orderedIds);
  @override
  List<Object?> get props => [orderedIds];
}

// ── States ─────────────────────────────────────────────────────────────
