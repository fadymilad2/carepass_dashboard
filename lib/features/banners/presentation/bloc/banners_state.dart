part of 'banners_bloc.dart';

abstract class BannersState extends Equatable {
  const BannersState();
  @override
  List<Object?> get props => [];
}

class BannersInitial extends BannersState {}

class BannersLoading extends BannersState {}

class BannersLoaded extends BannersState {
  final List<BannerEntity> banners;
  const BannersLoaded(this.banners);
  int get activeCount => banners.where((b) => b.isActive).length;
  @override
  List<Object?> get props => [banners];
}

class BannersActionSuccess extends BannersState {
  final String message;
  final List<BannerEntity> banners;
  const BannersActionSuccess({required this.message, required this.banners});
  @override
  List<Object?> get props => [message, banners];
}

class BannersError extends BannersState {
  final String message;
  const BannersError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────────
