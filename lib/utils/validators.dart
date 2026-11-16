/// Form validators. Each returns null when valid, or the error message shown
/// under the field, so they plug straight into `TextFormField(validator: ...)`.
///
/// Messages match the 2.1 wireframes.
class Validators {
  static const universityDomain = '@sabanciuniv.edu';
  static const minPasswordLength = 6;
  static const minParticipants = 2;
  static const maxParticipants = 100;
  static const maxTitleLength = 60;
  static const maxDescriptionLength = 500;

  static final _emailPattern = RegExp(r'^[a-z0-9._%+-]+@sabanciuniv\.edu$');

  // ---- Auth ----

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Enter your full name';
    return null;
  }

  static String? universityEmail(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Use your $universityDomain email';
    return null;
  }

  static String? department(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Department is required';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }

  /// Usage: `validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text)`
  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // ---- Create / Edit Event ----

  static String? eventTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length > maxTitleLength) {
      return 'Title must be at most $maxTitleLength characters';
    }
    return null;
  }

  /// For dropdowns: `validator: (v) => Validators.requiredChoice(v, 'Category')`
  static String? requiredChoice(Object? value, String fieldName) {
    if (value == null || (value is String && value.isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates the combined date + time picked on the form.
  /// Pass null if either picker is still empty.
  static String? eventDateTime(DateTime? value, {DateTime? now}) {
    if (value == null) return 'Date and time are required';
    if (value.isBefore(now ?? DateTime.now())) {
      return 'Event must be in the future';
    }
    return null;
  }

  /// [currentAttendees] is used on Edit so capacity can't drop below the
  /// number of people already joined.
  static String? maxParticipantsField(
    String? value, {
    int currentAttendees = 0,
  }) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n < minParticipants || n > maxParticipants) {
      return 'Value must be between $minParticipants and $maxParticipants';
    }
    if (n < currentAttendees) {
      return '$currentAttendees people already joined';
    }
    return null;
  }

  static String? description(String? value) {
    if ((value?.length ?? 0) > maxDescriptionLength) {
      return 'Description must be at most $maxDescriptionLength characters';
    }
    return null;
  }
}
