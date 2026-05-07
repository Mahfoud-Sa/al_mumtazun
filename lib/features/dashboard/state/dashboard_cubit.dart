import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardState {
  final int rangeIndex; // 0 weekly, 1 last30, 2 yearly
  const DashboardState({required this.rangeIndex});
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState(rangeIndex: 1));

  void setRangeIndex(int index) => emit(DashboardState(rangeIndex: index));
}

