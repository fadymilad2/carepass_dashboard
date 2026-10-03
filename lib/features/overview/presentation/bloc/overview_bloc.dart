import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/overview_entities.dart';
import '../../domain/usecases/get_overview.dart';

part 'overview_event.dart';
part 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final GetOverviewData _getOverview;

  OverviewBloc({required GetOverviewData getOverview})
    : _getOverview = getOverview,
      super(OverviewInitial()) {
    on<OverviewEvent>((event, emit) async {
      if (event is OverviewLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  Future<void> _onLoad(
    OverviewLoadRequested e,
    Emitter<OverviewState> emit,
  ) async {
    emit(OverviewLoading());
    final result = await _getOverview();

    if (result.isLeft()) {
      emit(OverviewError(result.fold((f) => f, (_) => '')));
      return;
    }

    emit(OverviewLoaded(result.getOrElse(() => throw Exception())));
  }
}
