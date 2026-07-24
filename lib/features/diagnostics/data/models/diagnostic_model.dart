import '../../domain/entities/diagnostic.dart';

class DiagnosticModel extends Diagnostic {
  const DiagnosticModel({
    required super.id,
    required super.diagnosticCode,
    required super.title,
    super.subtitle,
    super.description,
    super.symptoms,
    super.possibleCause,
    super.recommendedSolution,
    super.images,
    required super.severity,
    required super.status,
    super.technicianName,
    required super.createdAt,
    super.updatedAt,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    List<String>? imagesList;
    if (json['images'] is List) {
      imagesList = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['images'] is String && (json['images'] as String).isNotEmpty) {
      imagesList = [json['images'] as String];
    }

    return DiagnosticModel(
      id: _readInt(json['id']),
      diagnosticCode: json['diagnosticCode']?.toString() ??
          json['code']?.toString() ??
          'DIAG-${json['id'] ?? 0}',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      symptoms: json['symptoms']?.toString(),
      possibleCause: json['possibleCause']?.toString() ?? json['cause']?.toString(),
      recommendedSolution: json['recommendedSolution']?.toString() ?? json['solution']?.toString(),
      images: imagesList,
      severity: json['severity']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      technicianName: json['technicianName']?.toString() ?? json['technician']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  factory DiagnosticModel.fromEntity(Diagnostic diagnostic) {
    return DiagnosticModel(
      id: diagnostic.id,
      diagnosticCode: diagnostic.diagnosticCode,
      title: diagnostic.title,
      subtitle: diagnostic.subtitle,
      description: diagnostic.description,
      symptoms: diagnostic.symptoms,
      possibleCause: diagnostic.possibleCause,
      recommendedSolution: diagnostic.recommendedSolution,
      images: diagnostic.images,
      severity: diagnostic.severity,
      status: diagnostic.status,
      technicianName: diagnostic.technicianName,
      createdAt: diagnostic.createdAt,
      updatedAt: diagnostic.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosticCode': diagnosticCode,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'symptoms': symptoms,
      'possibleCause': possibleCause,
      'recommendedSolution': recommendedSolution,
      'images': images,
      'severity': severity,
      'status': status,
      'technicianName': technicianName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
