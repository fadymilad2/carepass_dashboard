part of 'overview_bloc.dart';

abstract class OverviewState extends Equatable {
  const OverviewState();
  @override
  List<Object?> get props => [];
}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  final OverviewData data;
  const OverviewLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class OverviewError extends OverviewState {
  final String message;
  const OverviewError(this.message);
  @override
  List<Object?> get props => [message];
}
