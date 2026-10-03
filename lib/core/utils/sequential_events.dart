import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps reads and mutations in dispatch order within one feature.
EventTransformer<E> sequentialEvents<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
