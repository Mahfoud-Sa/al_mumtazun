import 'package:equatable/equatable.dart';

import 'compound.dart';

class CompoundPage extends Equatable {
  final List<Compound> compounds;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  const CompoundPage({
    required this.compounds,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [compounds, page, size, totalCount, totalPages];
}
