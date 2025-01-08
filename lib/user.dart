class User {
  final int id;
  final bool active;
  final String sex;
  final String name;

  User({
    required this.id,
    required this.active,
    required this.sex,
    required this.name,
  });

  // Factory constructor to create a User instance from a map (e.g., SQLite row).
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      active: map['active'] == 'true',
      sex: map['sex'],
      name: map['name'],
    );
  }

  // Converts a User instance into a map (for inserting/updating SQLite rows).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'active': active == true ? "1" : "0", // Convert bool to string to match SQL TEXT type
      'sex': sex,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, active: $active, sex: $sex, name: $name)';
  }
}
