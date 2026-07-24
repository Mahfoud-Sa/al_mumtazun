import 'package:equatable/equatable.dart';

class Diagnostic extends Equatable {
  final int id;
  final String diagnosticCode;
  final String title;
  final String? subtitle;
  final String? description;
  final String? symptoms;
  final String? possibleCause;
  final String? recommendedSolution;
  final List<String>? images;
  final String severity;
  final String status;
  final String? technicianName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Diagnostic({
    required this.id,
    required this.diagnosticCode,
    required this.title,
    this.subtitle,
    this.description,
    this.symptoms,
    this.possibleCause,
    this.recommendedSolution,
    this.images,
    required this.severity,
    required this.status,
    this.technicianName,
    required this.createdAt,
    this.updatedAt,
  });

  Diagnostic copyWith({
    int? id,
    String? diagnosticCode,
    String? title,
    String? subtitle,
    String? description,
    String? symptoms,
    String? possibleCause,
    String? recommendedSolution,
    List<String>? images,
    String? severity,
    String? status,
    String? technicianName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diagnostic(
      id: id ?? this.id,
      diagnosticCode: diagnosticCode ?? this.diagnosticCode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      possibleCause: possibleCause ?? this.possibleCause,
      recommendedSolution: recommendedSolution ?? this.recommendedSolution,
      images: images ?? this.images,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      technicianName: technicianName ?? this.technicianName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        diagnosticCode,
        title,
        subtitle,
        description,
        symptoms,
        possibleCause,
        recommendedSolution,
        images,
        severity,
        status,
        technicianName,
        createdAt,
        updatedAt,
      ];
}
