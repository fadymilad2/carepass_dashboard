part of 'overview_bloc.dart';

abstract class OverviewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OverviewLoadRequested extends OverviewEvent {}
