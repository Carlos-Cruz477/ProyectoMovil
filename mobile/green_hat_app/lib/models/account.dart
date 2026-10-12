class Account {
  const Account({
    required this.id,
    required this.email,
    required this.name,
    required this.businessSector,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String businessSector;
  final DateTime createdAt;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      businessSector: json['businessSector'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
