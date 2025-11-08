class LiveSessionModel {
  final String id;
  final String website;
  final String clientName;
  final DateTime startedAt;
  final bool active;

  LiveSessionModel({
    required this.id,
    required this.website,
    required this.clientName,
    required this.startedAt,
    required this.active,
  });

  factory LiveSessionModel.fromMap(Map<String, dynamic> map) {
    return LiveSessionModel(
      id: map['id'],
      website: map['website'] ?? '',
      clientName: map['clients']?['company_name'] ?? 'Unknown Client',
      startedAt: DateTime.parse(map['started_at']),
      active: map['active'] ?? false,
    );
  }
}
