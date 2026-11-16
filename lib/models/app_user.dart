/// A registered SuMeet user (Sabancı University student or staff member).
class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String department;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
  });

  /// "Ayşe Yılmaz" -> "Ayşe Y." (used in attendee lists).
  String get shortName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return fullName;
    return '${parts.first} ${parts.last[0]}.';
  }

  /// First letter for the avatar circle.
  String get initial => fullName.isEmpty ? '?' : fullName[0].toUpperCase();

  AppUser copyWith({String? fullName, String? department}) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      department: department ?? this.department,
    );
  }

  @override
  bool operator ==(Object other) => other is AppUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
