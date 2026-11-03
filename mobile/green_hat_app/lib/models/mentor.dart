class Mentor {
  const Mentor({required this.id, required this.name, required this.role,
    required this.headline, required this.specialty, required this.sector,
    required this.location, required this.description, required this.achievement,
    required this.responseTime, required this.kind, this.ticket,
    this.verified = false, this.demo = false});

  final String id, name, role, headline, specialty, sector, location;
  final String description, achievement, responseTime, kind;
  final String? ticket;
  final bool verified, demo;
  bool get isInvestor => kind == 'investor';
  String get initials => name.split(' ').take(2).map((s) => s[0]).join();

  factory Mentor.fromJson(Map<String, dynamic> json) => Mentor(
    id: json['id'] as String, name: json['name'] as String,
    role: json['role'] as String, headline: json['headline'] as String,
    specialty: json['specialty'] as String, sector: json['sector'] as String,
    location: json['location'] as String, description: json['description'] as String,
    achievement: json['achievement'] as String, responseTime: json['responseTime'] as String,
    kind: json['kind'] as String, ticket: json['ticket'] as String?,
    verified: json['verified'] == true, demo: json['demo'] == true,
  );
}
